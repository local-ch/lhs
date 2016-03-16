require 'rails_helper'

describe LHS::Collection do
  let(:datastore) { 'http://local.ch/v2' }

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint ':datastore/:campaign_id/feedbacks'
      endpoint ':datastore/feedbacks'
    end
  end

  context 'all' do
    it 'fetches all records from the backend' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(status: 200, body: { items: (1..100).to_a, total: 300, limit: 100, offset: 0 }.to_json)
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=101")
        .to_return(status: 200, body: { items: (101..200).to_a, total: 300, limit: 100, offset: 101 }.to_json)
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=201")
        .to_return(status: 200, body: { items: (201..300).to_a, total: 300, limit: 100, offset: 201 }.to_json)
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._data._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 300
      expect(all.last).to eq 300
    end

    it 'also fetches all when there is not meta information for limit' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(status: 200, body: { items: (1..100).to_a, total: 300, offset: 0 }.to_json)
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=101")
        .to_return(status: 200, body: { items: (101..200).to_a, total: 300, offset: 101 }.to_json)
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=201")
        .to_return(status: 200, body: { items: (201..300).to_a, total: 300, offset: 201 }.to_json)
      all = Record.all
      expect(all).to be_kind_of Record
      expect(all._proxy).to be_kind_of LHS::Collection
      expect(all.count).to eq 300
      expect(all.last).to eq 300
    end

    it 'also works when there is no item in the first response' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
        .to_return(status: 200, body: { items: [], total: 300, offset: 0 }.to_json)
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

    # TODO: is this the right place for the following two spec examples?

    it 'converts to json' do
      stub_request(:get, %r{/feedbacks}).to_return(body: [{ foo: 'foo', bar: 'bar' }].to_json)
      all = Record.all
      expect(all.as_json).to eq [{ 'foo' => 'foo', 'bar' => 'bar' }]
      expect(all.to_json).to eq "[{\"foo\":\"foo\",\"bar\":\"bar\"}]"
    end

    it 'converts with options to json' do
      stub_request(:get, %r{/feedbacks}).to_return(body: [{ foo: 'foo', bar: 'bar' }].to_json)
      all = Record.all
      expect(all.as_json(only: 'foo')).to eq [{ 'foo' => 'foo' }]
      expect(all.to_json(only: 'foo')).to eq "[{\"foo\":\"foo\"}]"
    end
  end
end
