# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  before { LHC.config.placeholder('datastore', datastore) }
  let(:datastore) { 'http://local.ch/v2' }

  context 'default pagination behaviour' do
    before do
      class Record < LHS::Record
        endpoint '{+datastore}/feedbacks'
      end
    end

    it 'also works when there is no item in the first response' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(
          status: 200,
          body: { items: [], total: 200, offset: 0 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=100")
        .to_return(
          status: 200,
          body: { items: [], total: 200, offset: 0 }.to_json
        )
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._proxy).to be_kind_of LHS::Collection
      expect(all.length).to eq 0
    end

    it 'also works when there is no total in the stubbing' do
      stub_request(:get, "http://local.ch/v2/feedbacks?limit=100").to_return(body: { items: (1..100).to_a }.to_json)
      stub_request(:get, "http://local.ch/v2/feedbacks?limit=100&offset=100").to_return(body: { items: [] }.to_json)
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._proxy).to be_kind_of LHS::Collection
      expect(all.length).to eq 100
    end

    it 'also works when there is no key "items" in the stubbing' do
      stub_request(:get, "http://local.ch/v2/feedbacks?limit=100").to_return(body: (1..100).to_a.to_json)
      stub_request(:get, "http://local.ch/v2/feedbacks?limit=100&offset=100").to_return(body: [].to_json)
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._proxy).to be_kind_of LHS::Collection
      expect(all.length).to eq 100
    end
  end

  context 'pagination using offset(0,100,200,...)' do
    before do
      class Record < LHS::Record
        configuration pagination_strategy: 'offset', pagination_key: 'offset'
        endpoint '{+datastore}/feedbacks'
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
      last_request = stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=200")
        .to_return(
          status: 200,
          body: { items: (201..300).to_a, limit: 100, total: 300, offset: 200 }.to_json
        )
      all = Record.all
      all.first # fetch/resolve
      assert_requested last_request
      expect(all).to be_kind_of Record
      expect(all._data._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 300
      expect(all.last).to eq 300
    end

    it 'fetches all, also if there is a rest and the total is not divideable trough the limit' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(
          status: 200,
          body: { items: (1..100).to_a, limit: 100, total: 223, offset: 0 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=100")
        .to_return(
          status: 200,
          body: { items: (101..200).to_a, limit: 100, total: 223, offset: 100 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=200")
        .to_return(
          status: 200,
          body: { items: (201..223).to_a, limit: 100, total: 223, offset: 200 }.to_json
        )
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._data._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 223
      expect(all.last).to eq 223
    end

    it 'also fetches all when there is no meta information for limit' do
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

  context 'pagination using page(1,2,3,...)' do
    before do
      class Record < LHS::Record
        configuration pagination_strategy: 'page', pagination_key: 'page'
        endpoint '{+datastore}/feedbacks'
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

    it 'also fetches all when there is no meta information for limit' do
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

    it 'fetches all, also if there is a rest and the total is not divideable trough the limit' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(
          status: 200,
          body: { items: (1..100).to_a, limit: 100, total: 223, page: 1 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&page=2")
        .to_return(
          status: 200,
          body: { items: (101..200).to_a, limit: 100, total: 223, page: 2 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&page=3")
        .to_return(
          status: 200,
          body: { items: (201..223).to_a, limit: 100, total: 223, page: 3 }.to_json
        )
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._data._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 223
      expect(all.last).to eq 223
    end
  end

  context 'pagination using start(1,101,201,...)' do
    before do
      class Record < LHS::Record
        configuration pagination_strategy: 'start', pagination_key: 'start'
        endpoint '{+datastore}/feedbacks'
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

    it 'also fetches all when there is no meta information for limit' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(
          status: 200,
          body: { items: (1..100).to_a, total: 300, start: 1 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&start=101")
        .to_return(
          status: 200,
          body: { items: (101..200).to_a, total: 300, start: 101 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&start=201")
        .to_return(
          status: 200,
          body: { items: (201..300).to_a, total: 300, start: 201 }.to_json
        )
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 300
      expect(all.last).to eq 300
    end

    it 'fetches all, also if there is a rest and the total is not divideable trough the limit' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(
          status: 200,
          body: { items: (1..100).to_a, limit: 100, total: 223, start: 1 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&start=101")
        .to_return(
          status: 200,
          body: { items: (101..200).to_a, limit: 100, total: 223, start: 101 }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&start=201")
        .to_return(
          status: 200,
          body: { items: (201..223).to_a, limit: 100, total: 223, start: 201 }.to_json
        )
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._data._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 223
      expect(all.last).to eq 223
    end
  end

  context 'pagination using links' do
    before do
      class Record < LHS::Record
        configuration pagination_strategy: 'link'
        endpoint '{+datastore}/feedbacks'
      end
    end

    it 'fetches all records from the backend' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(
          status: 200,
          body: { items: (1..100).to_a, limit: 100, next: { href: "#{datastore}/feedbacks?limit=100&cursor=x" } }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&cursor=x")
        .to_return(
          status: 200,
          body: { items: (101..200).to_a, limit: 100, next: { href: "#{datastore}/feedbacks?limit=100&cursor=y" } }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&cursor=y")
        .to_return(
          status: 200,
          body: { items: (201..300).to_a, limit: 100, next: { href: "#{datastore}/feedbacks?limit=100&cursor=z" } }.to_json
        )
      stub_request(:get, "#{datastore}/feedbacks?limit=100&cursor=z")
        .to_return(
          status: 200,
          body: { items: [], limit: 100 }.to_json
        )
      all = Record.all

      expect(all).to be_kind_of Record
      expect(all._data._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 300
      expect(all.last).to eq 300
    end
  end
end
