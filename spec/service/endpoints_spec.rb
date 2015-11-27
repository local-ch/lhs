require 'rails_helper'

describe LHS::Service do

  context 'endpoints' do

    let(:datastore) { 'http://local.ch/v2' }

    before(:each) do
      LHC.config.placeholder(:datastore, datastore)
      class SomeService < LHS::Service
        endpoint ':datastore/entries/:entry_id/content-ads/:campaign_id/feedbacks'
        endpoint ':datastore/:campaign_id/feedbacks'
        endpoint ':datastore/feedbacks'
      end
    end

    it 'stores all the endpoints by url' do
      expect(LHS::Service::Endpoints.all[':datastore/entries/:entry_id/content-ads/:campaign_id/feedbacks']).to be 
      expect(LHS::Service::Endpoints.all[':datastore/:campaign_id/feedbacks']).to be
      expect(LHS::Service::Endpoints.all[':datastore/feedbacks']).to be
    end

    it 'stores the endpoints of the service' do
      expect(SomeService.instance.endpoints.count).to eq 3
      expect(SomeService.instance.endpoints[0].url).to eq ':datastore/entries/:entry_id/content-ads/:campaign_id/feedbacks'
      expect(SomeService.instance.endpoints[1].url).to eq ':datastore/:campaign_id/feedbacks'
      expect(SomeService.instance.endpoints[2].url).to eq ':datastore/feedbacks'
    end

    it 'finds the endpoint by the one with the most route param hits' do
      expect(
        SomeService.instance.find_endpoint(campaign_id: '12345').url
      ).to eq ':datastore/:campaign_id/feedbacks'
      expect(
        SomeService.instance.find_endpoint(campaign_id: '12345', entry_id: '123').url
      ).to eq ':datastore/entries/:entry_id/content-ads/:campaign_id/feedbacks'
    end

    it 'finds the base endpoint (endpoint with least amount of route params)' do
      expect(
        SomeService.instance.find_endpoint.url
      ).to eq ':datastore/feedbacks'
    end

    context 'compute url from endpoint' do

      before(:each) do
        class Feedback < LHS::Service
          endpoint ':datastore/feedbacks'
          endpoint ':datastore/feedbacks/:id'
        end
      end

      it 'computes urls WITHOUT handling id separate' do
        stub_request(:get, "#{datastore}/feedbacks/1").to_return(status: 200)
        Feedback.find(1)
      end
    end

    context 'unsorted endpoints' do

      before(:each) do
        class AnotherService < LHS::Service
          endpoint ':datastore/feedbacks'
          endpoint ':datastore/:campaign_id/feedbacks'
          endpoint ':datastore/entries/:entry_id/content-ads/:campaign_id/feedbacks'
        end
      end

      it 'sorts endpoints before trying to find the best endpoint' do
        stub_request(:get, "#{datastore}/entries/123/content-ads/123/feedbacks").to_return(status: 200)
        AnotherService.where(campaign_id: 123, entry_id: 123)
      end

    end
  end
end
