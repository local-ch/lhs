require 'rails_helper'

describe LHS::Service do

  class SomeService < LHS::Service
    endpoint ':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks'
    endpoint ':datastore/v2/:campaign_id/feedbacks'
    endpoint ':datastore/v2/feedbacks'
  end

  context 'endpoints' do

    it 'stores the endpoints of the service' do
      expect(SomeService.instance.endpoints.count).to eq 3
      expect(SomeService.instance.endpoints[0]).to eq ':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks'
      expect(SomeService.instance.endpoints[1]).to eq ':datastore/v2/:campaign_id/feedbacks'
      expect(SomeService.instance.endpoints[2]).to eq ':datastore/v2/feedbacks'
    end

    it 'finds the endpoint by the one with the most route param hits' do
      expect(
        SomeService.instance.find_endpoint(campaign_id: '12345')
      ).to eq ':datastore/v2/:campaign_id/feedbacks'
      expect(
        SomeService.instance.find_endpoint(campaign_id: '12345', entry_id: '123')
      ).to eq ':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks'
    end

    it 'finds the base endpoint (endpoint with least amount of route params)' do
      expect(
        SomeService.instance.find_endpoint
      ).to eq ':datastore/v2/feedbacks'
    end

    context 'exceptions' do

      class MisconfiguredService < LHS::Service
        endpoint ':datastore/v2/feedbacks'
        endpoint ':datastore/v2/reviews'
        endpoint ':datastore/v2/:campaign_id/feedbacks'
        endpoint ':datastore/v2/:campaign_id/reviews'
      end

      it 'fails trying to find the base endpoint when multiple base endpoints are configured' do
        expect(
          ->{ MisconfiguredService.instance.find_endpoint }
        ).to raise_error('Multiple base endpoints found')
      end

    end
  end
end
