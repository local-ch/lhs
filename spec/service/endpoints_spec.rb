require 'rails_helper'

describe LHS::Service do

  context 'endpoints' do

    let(:datastore) { 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2' }

    before(:each) do
      LHC.config.injection(:datastore, datastore)
      class SomeService < LHS::Service
        endpoint ':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks'
        endpoint ':datastore/v2/:campaign_id/feedbacks'
        endpoint ':datastore/v2/feedbacks'
      end
    end

    it 'stores the endpoints of the service' do
      expect(SomeService.instance.endpoints.count).to eq 3
      expect(SomeService.instance.endpoints[0].url).to eq ':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks'
      expect(SomeService.instance.endpoints[1].url).to eq ':datastore/v2/:campaign_id/feedbacks'
      expect(SomeService.instance.endpoints[2].url).to eq ':datastore/v2/feedbacks'
    end

    it 'finds the endpoint by the one with the most route param hits' do
      expect(
        SomeService.instance.find_endpoint(campaign_id: '12345').url
      ).to eq ':datastore/v2/:campaign_id/feedbacks'
      expect(
        SomeService.instance.find_endpoint(campaign_id: '12345', entry_id: '123').url
      ).to eq ':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks'
    end

    it 'finds the base endpoint (endpoint with least amount of route params)' do
      expect(
        SomeService.instance.find_endpoint.url
      ).to eq ':datastore/v2/feedbacks'
    end
  end
end
