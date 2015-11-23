require 'rails_helper'

describe LHS::Endpoint do

  context 'for url' do

    before(:each) do
      class SomeService < LHS::Service
        endpoint ':datastore/entries/:entry_id/content-ads/:campaign_id/feedbacks'
        endpoint ':datastore/:campaign_id/feedbacks'
        endpoint ':datastore/feedbacks'
      end
    end

    it 'provides the endpoint for a given url' do
      expect(
        LHS::Endpoint.for_url('http://datastore.local.ch/v2/entries/123/content-ads/456/feedbacks').url
      ).to eq ':datastore/entries/:entry_id/content-ads/:campaign_id/feedbacks'
      expect(
        LHS::Endpoint.for_url('http://datastore.local.ch/123/feedbacks').url
      ).to eq ':datastore/:campaign_id/feedbacks'
      expect(
        LHS::Endpoint.for_url('http://datastore.local.ch/feedbacks').url
      ).to eq ':datastore/feedbacks'
    end
  end
end