require 'rails_helper'

describe LHS::Collection do

  let(:datastore) { 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2' }

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class SomeService < LHS::Service
      endpoint ':datastore/:campaign_id/feedbacks'
      endpoint ':datastore/feedbacks'
    end
  end

  context 'all' do

    it 'fetches all records from the backend' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100")
      .to_return(status: 200, body: {items: (1..100).to_a, total: 300, limit: 100, offset: 0}.to_json)
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=101")
      .to_return(status: 200, body: {items: (101..200).to_a, total: 300, limit: 100, offset: 101}.to_json)
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=201")
      .to_return(status: 200, body: {items: (201..300).to_a, total: 300, limit: 100, offset: 201}.to_json)
      all = SomeService.all
      expect(all).to be_kind_of LHS::Data
      expect(all._proxy_).to be_kind_of LHS::Collection
      expect(all.count).to eq 300
      expect(all[299]).to eq 300
    end
  end
end
