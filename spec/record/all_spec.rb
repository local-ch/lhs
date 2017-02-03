require 'rails_helper'

describe LHS::Record do
  before(:each) do
    class Record < LHS::Record
      endpoint 'http://datastore/feedbacks'
    end
  end

  context 'all' do
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
        records = Record.includes(:product).includes_all(:options).all(color: 'blue')
        expect(records.length).to eq total
        expect(first_page_request).to have_been_requested.times(1)
        expect(second_page_request).to have_been_requested.times(1)
        expect(third_page_request).to have_been_requested.times(1)
      end
    end
  end
end
