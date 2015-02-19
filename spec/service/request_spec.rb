require 'rails_helper'

describe LHS::Service do

  context 'url pattern' do

    let(:datastore) { 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2' }

    before(:each) do
      LHC.config.placeholder(:datastore, datastore)
      class SomeService < LHS::Service
        endpoint ':datastore/content-ads/:campaign_id/feedbacks'
        endpoint ':datastore/feedbacks'
      end
    end

    it 'is using params as query params explicitly when provided in params namespace' do
      stub_request(:get, "#{datastore}/content-ads/123/feedbacks?campaign_id=456").to_return(status: 200)
      SomeService.where(campaign_id: 123, params: { campaign_id: '456' })
    end
  end
end
