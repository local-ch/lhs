require 'rails_helper'

describe LHS::Record do
  context 'endpoints' do
    let(:datastore) { 'http://local.ch/v2' }

    before(:each) do
      LHC.config.placeholder(:datastore, datastore)
      class Record < LHS::Record
        endpoint ':datastore/entries/:entry_id/content-ads/:campaign_id/feedbacks'
        endpoint ':datastore/:campaign_id/feedbacks'
        endpoint ':datastore/feedbacks'
      end
    end

    it 'stores all the endpoints by url' do
      expect(LHS::Record::Endpoints.all[':datastore/entries/:entry_id/content-ads/:campaign_id/feedbacks']).to be
      expect(LHS::Record::Endpoints.all[':datastore/:campaign_id/feedbacks']).to be
      expect(LHS::Record::Endpoints.all[':datastore/feedbacks']).to be
    end

    it 'stores the endpoints of the service' do
      expect(Record.endpoints.count).to eq 3
      expect(Record.endpoints[0].url).to eq ':datastore/entries/:entry_id/content-ads/:campaign_id/feedbacks'
      expect(Record.endpoints[1].url).to eq ':datastore/:campaign_id/feedbacks'
      expect(Record.endpoints[2].url).to eq ':datastore/feedbacks'
    end

    it 'finds the endpoint by the one with the most route param hits' do
      expect(
        Record.find_endpoint(campaign_id: '12345').url
      ).to eq ':datastore/:campaign_id/feedbacks'
      expect(
        Record.find_endpoint(campaign_id: '12345', entry_id: '123').url
      ).to eq ':datastore/entries/:entry_id/content-ads/:campaign_id/feedbacks'
    end

    it 'finds the base endpoint (endpoint with least amount of route params)' do
      expect(
        Record.find_endpoint.url
      ).to eq ':datastore/feedbacks'
    end

    context 'compute url from endpoint' do
      before(:each) do
        class Feedback < LHS::Record
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
        class AnotherRecord < LHS::Record
          endpoint ':datastore/feedbacks'
          endpoint ':datastore/:campaign_id/feedbacks'
          endpoint ':datastore/entries/:entry_id/content-ads/:campaign_id/feedbacks'
        end
      end

      it 'sorts endpoints before trying to find the best endpoint' do
        stub_request(:get, "#{datastore}/entries/123/content-ads/123/feedbacks").to_return(status: 200)
        AnotherRecord.where(campaign_id: 123, entry_id: 123)
      end
    end

    context 'includes data without considering base endpoint of parent record if url is present' do
      before(:each) do
        class Contract < LHS::Record
          endpoint ':datastore/contracts/:id'
          endpoint ':datastore/entry/:entry_id/contracts'
        end
      end

      it 'uses urls instead of trying to find base endpoint of parent class' do
        stub_request(:get, "#{datastore}/entry/123/contracts?limit=100")
          .to_return(body: [{ product: { href: "#{datastore}/products/LBC" } }].to_json)
        stub_request(:get, "#{datastore}/entry/123/contracts?limit=100&offset=100")
          .to_return(body: [].to_json)
        stub_request(:get, "#{datastore}/products/LBC")
          .to_return(body: { name: 'Local Business Card' }.to_json)
        expect(lambda {
          Contract.includes(:product).where(entry_id: '123').all.first
        }).not_to raise_error # Multiple base endpoints found
      end
    end
  end
end
