require 'rails_helper'

describe LHS::Collection do

  before(:each) do
    class SomeService < LHS::Service
      endpoint ':datastore/v2/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end

  context 'all' do

    it 'fetches all records from the backend' do
      stub_request(:get, 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks?limit=100')
      .to_return(status: 200, body: {items: (1..100).to_a, total: 300, limit: 100, offset: 0}.to_json)
      stub_request(:get, 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks?limit=100&offset=101')
      .to_return(status: 200, body: {items: (101..200).to_a, total: 300, limit: 100, offset: 101}.to_json)
      stub_request(:get, 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks?limit=100&offset=201')
      .to_return(status: 200, body: {items: (201..300).to_a, total: 300, limit: 100, offset: 201}.to_json)
      all = SomeService.all
      expect(all).to be_kind_of LHS::Data
      expect(all._proxy_).to be_kind_of LHS::Collection
      expect(all.count).to eq 300
      expect(all[299]).to eq 300
    end
  end
end
