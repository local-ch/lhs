# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'all' do
    before do
      class Record < LHS::Record
        endpoint 'http://datastore/feedbacks'
      end
    end

    it 'is querying endpoint without pagination when using all' do
      stub_request(:get, "http://datastore/feedbacks?limit=100").to_return(body: { items: 300.times.map { { foo: 'bar' } }, total: 300 }.to_json)
      records = Record.all
      expect(records).to be_kind_of Record
      expect(records.size).to eq(300)
    end

    context 'is chainable with where and works like where' do
      let(:total) { 22 }
      let(:limit) { 10 }
      let!(:first_page_request) do
        stub_request(:get, "http://datastore/feedbacks?color=blue&limit=100")
          .to_return(body: { items: 10.times.map { { foo: 'bar' } }, total: total, limit: limit, offset: 0 }.to_json)
      end
      let!(:second_page_request) do
        stub_request(:get, "http://datastore/feedbacks?color=blue&limit=#{limit}&offset=10")
          .to_return(body: { items: 10.times.map { { foo: 'bar' } }, total: total, limit: limit, offset: 10 }.to_json)
      end
      let!(:third_page_request) do
        stub_request(:get, "http://datastore/feedbacks?color=blue&limit=#{limit}&offset=20")
          .to_return(body: { items: 2.times.map { { foo: 'bar' } }, total: total, limit: limit, offset: 20 }.to_json)
      end

      it 'fetches all remote objects' do
        records = Record.where(color: 'blue').all
        expect(records.length).to eq total
        expect(first_page_request).to have_been_requested.times(1)
        expect(second_page_request).to have_been_requested.times(1)
        expect(third_page_request).to have_been_requested.times(1)
        records = Record.all.where(color: 'blue')
        expect(records.length).to eq total
        expect(first_page_request).to have_been_requested.times(2)
        expect(second_page_request).to have_been_requested.times(2)
        expect(third_page_request).to have_been_requested.times(2)
        records = Record.all(color: 'blue')
        expect(records.length).to eq total
        expect(first_page_request).to have_been_requested.times(3)
        expect(second_page_request).to have_been_requested.times(3)
        expect(third_page_request).to have_been_requested.times(3)
      end

      it 'works in combination with include and includes' do
        records = Record.includes_first_page(:product).includes(:options).all(color: 'blue')
        expect(records.length).to eq total
        expect(first_page_request).to have_been_requested.times(1)
        expect(second_page_request).to have_been_requested.times(1)
        expect(third_page_request).to have_been_requested.times(1)
      end
    end
  end

  context 'all without current page indicator' do
    before do
      class Category < LHS::Record
        configuration(
          items_key: %i(response results),
          limit_key: :max,
          pagination_key: :offset,
          pagination_strategy: :offset
        )

        endpoint 'http://store/categories'
      end
    end

    def stub_batch(url, items = 10)
      stub_request(:get, url)
        .to_return(
          body: {
            response: {
              results: items.times.map { { name: 'category' } }
            }
          }.to_json
        )
    end

    it 'is able to fetch all remote objects without any current page indicator by simply increasing the offset until response is empty with a limit' do
      stub_batch('http://store/categories?language=en&max=10&offset=0')
      stub_batch('http://store/categories?language=en&max=10&offset=10')
      stub_batch('http://store/categories?language=en&max=10&offset=20')
      stub_batch('http://store/categories?language=en&max=10&offset=30', 0)
      records = Category.limit(10).all(language: 'en').fetch
      expect(records.length).to eq 30
    end

    it 'is able to fetch all remote objects without any current page indicator by simply increasing the offset until response is empty' do
      stub_batch('http://store/categories?language=en&max=100', 100)
      stub_batch('http://store/categories?language=en&max=100&offset=100', 100)
      stub_batch('http://store/categories?language=en&max=100&offset=200', 100)
      stub_batch('http://store/categories?language=en&max=100&offset=300', 0)
      records = Category.all(language: 'en').fetch
      expect(records.length).to eq 300
    end

    it 'outputs a warning, if all is requested, but endpoint does not implement pagination meta data' do
      stub_batch('http://store/categories?language=en&max=100', 100)
      stub_batch('http://store/categories?language=en&max=100&offset=100', 100)
      stub_batch('http://store/categories?language=en&max=100&offset=200', 100)
      stub_batch('http://store/categories?language=en&max=100&offset=300', 0)
      expect(-> { Category.all(language: 'en').fetch }).to output(
        %r{\[Warning\] "all" has been requested, but endpoint does not provide pagination meta data. If you just want to fetch the first response, use "where" or "fetch".}
      ).to_stderr
    end

    context 'with record set to not paginated' do
      before do
        class Record < LHS::Record
          configuration paginated: false
          endpoint 'http://datastore/records'
        end
      end

      it 'just fetches the first response' do
        stub_request(:get, "http://datastore/records")
          .to_return(body: [{ name: 'Steve' }].to_json)
        records = Record.all
        expect(records.first.name).to eq 'Steve'
      end
    end
  end
end
