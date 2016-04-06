
require 'rails_helper'

describe LHS::Record do

  before(:each) { LHC.config.placeholder('datastore', datastore) }
  let(:datastore) { 'http://local.ch/v2' }

  context 'default pagination behaviour' do

    before(:each) do
      class Record < LHS::Record
        endpoint ':datastore/feedbacks'
      end
    end

    it 'also works when there is no item in the first response' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(
          status: 200,
          body: { items: [], total: 300, offset: 0 }.to_json
        )
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 0
    end

    it 'also works when there is no total in the stubbing' do
      stub_request(:get, %r{/feedbacks}).to_return(body: { items: (1..100).to_a }.to_json)
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 100
    end

    it 'also works when there is no key "items" in the stubbing' do
      stub_request(:get, %r{/feedbacks}).to_return(body: (1..100).to_a.to_json)
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 100
    end
  end

  context 'pagination using offset(0,100,200,...)' do

    context 'pagination_strategy:"offset" is used by default' do

      it 'fetches all records from the backend' do
        stub_request(:get, "#{datastore}/feedbacks?limit=100")
          .to_return(
            status: 200,
            body: { items: (1..100).to_a, limit: 100, total: 300, offset: 0 }.to_json
          )
        stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=100")
          .to_return(
            status: 200,
            body: { items: (101..200).to_a, limit: 100, total: 300, offset: 100 }.to_json
          )
        stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=200")
          .to_return(
            status: 200,
            body: { items: (201..300).to_a, limit: 100, total: 300, offset: 200 }.to_json
          )
        all = Record.all
        expect(all).to be_kind_of Record
        expect(all._data._proxy).to be_kind_of LHS::Collection
        expect(all.count).to eq 300
        expect(all.last).to eq 300
      end

      it 'also fetches all when there is not meta information for limit' do
        stub_request(:get, "#{datastore}/feedbacks?limit=100")
          .to_return(
            status: 200,
            body: { items: (1..100).to_a, total: 300, offset: 0 }.to_json
          )
        stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=100")
          .to_return(
            status: 200,
            body: { items: (101..200).to_a, total: 300, offset: 100 }.to_json
          )
        stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=200")
          .to_return(
            status: 200,
            body: { items: (201..300).to_a, total: 300, offset: 200 }.to_json
          )
        all = Record.all
        expect(all).to be_kind_of Record
        expect(all._proxy).to be_kind_of LHS::Collection
        expect(all.count).to eq 300
        expect(all.last).to eq 300
      end
    end

    context 'using pagination_strategy:"offset" explicitly' do

      before(:each) do
        class Record < LHS::Record
          configuration pagination_strategy: 'offset', pagination_key: 'offset'
          endpoint ':datastore/feedbacks'
        end
      end

      it 'fetches all records from the backend' do
        stub_request(:get, "#{datastore}/feedbacks?limit=100")
          .to_return(
            status: 200,
            body: { items: (1..100).to_a, limit: 100, total: 300, offset: 0 }.to_json
          )
        stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=100")
          .to_return(
            status: 200,
            body: { items: (101..200).to_a, limit: 100, total: 300, offset: 100 }.to_json
          )
        stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=200")
          .to_return(
            status: 200,
            body: { items: (201..300).to_a, limit: 100, total: 300, offset: 200 }.to_json
          )
        all = Record.all
        expect(all).to be_kind_of Record
        expect(all._data._proxy).to be_kind_of LHS::Collection
        expect(all.count).to eq 300
        expect(all.last).to eq 300
      end

      it 'also fetches all when there is not meta information for limit' do
        stub_request(:get, "#{datastore}/feedbacks?limit=100")
          .to_return(
            status: 200,
            body: { items: (1..100).to_a, total: 300, offset: 0 }.to_json
          )
        stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=100")
          .to_return(
            status: 200,
            body: { items: (101..200).to_a, total: 300, offset: 100 }.to_json
          )
        stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=200")
          .to_return(
            status: 200,
            body: { items: (201..300).to_a, total: 300, offset: 200 }.to_json
          )
        all = Record.all
        expect(all).to be_kind_of Record
        expect(all._proxy).to be_kind_of LHS::Collection
        expect(all.count).to eq 300
        expect(all.last).to eq 300
      end
    end
  end

  context 'pagination using page(1,2,3,...)' do

    before(:each) do
      class Record < LHS::Record
        configuration pagination_strategy: 'page', pagination_key: 'page'
        endpoint ':datastore/feedbacks'
      end
    end

    it 'fetches all records from the backend' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(
          status: 200,
          body: { items: (1..100).to_a, limit: 100, total: 300, page: 1 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&page=2")
        .to_return(
          status: 200,
          body: { items: (101..200).to_a, limit: 100, total: 300, page: 2 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&page=3")
        .to_return(
          status: 200,
          body: { items: (201..300).to_a, limit: 100, total: 300, page: 3 }.to_json
        )
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._data._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 300
      expect(all.last).to eq 300
    end

    it 'also fetches all when there is not meta information for limit' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(
          status: 200,
          body: { items: (1..100).to_a, total: 300, page: 1 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&page=2")
        .to_return(
          status: 200,
          body: { items: (101..200).to_a, total: 300, page: 2 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&page=3")
        .to_return(
          status: 200,
          body: { items: (201..300).to_a, total: 300, page: 3 }.to_json
        )
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 300
      expect(all.last).to eq 300
    end

  end

  context 'pagination using start(1,101,201,...)' do

    before(:each) do
      class Record < LHS::Record
        configuration pagination_strategy: 'start', pagination_key: 'start'
        endpoint ':datastore/feedbacks'
      end
    end

    it 'fetches all records from the backend' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(
          status: 200,
          body: { items: (1..100).to_a, limit: 100, total: 300, start: 1 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&start=101")
        .to_return(
          status: 200,
          body: { items: (101..200).to_a, limit: 100, total: 300, start: 101 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&start=201")
        .to_return(
          status: 200,
          body: { items: (201..300).to_a, limit: 100, total: 300, start: 201 }.to_json
        )
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._data._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 300
      expect(all.last).to eq 300
    end

    it 'also fetches all when there is not meta information for limit' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(
          status: 200,
          body: { items: (1..100).to_a, total: 300, start: 1 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&start=101")
        .to_return(
          status: 200,
          body: { items: (101..200).to_a, total: 300, start: 2 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&start=201")
        .to_return(
          status: 200,
          body: { items: (201..300).to_a, total: 300, start: 3 }.to_json
        )
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 300
      expect(all.last).to eq 300
    end
  end
end
