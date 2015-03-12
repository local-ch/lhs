require 'rails_helper'

describe LHS::Service do

  let(:datastore) { 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2' }

  before(:each) do
    LHC.config.placeholder(:datastore, datastore)
    class SomeService < LHS::Service
      endpoint ':datastore/content-ads/:campaign_id/feedbacks'
      endpoint ':datastore/feedbacks'
    end
  end

  context 'find' do

    it 'finds a single unique record' do
      stub_request(:get, "#{datastore}/feedbacks/z12f-3asm3ngals").
      to_return(status: 200, body: load_json(:feedback))
      record = SomeService.find('z12f-3asm3ngals')
      expect(record.source_id).to be_kind_of String
    end

    it 'raises if nothing was found' do
      stub_request(:get, "#{datastore}/feedbacks/not-existing").
      to_return(status: 404)
      expect { SomeService.find('not-existing') }.to raise_error LHC::NotFound
    end

    it 'finds unique item by providing parameters' do
      stub_request(:get, "#{datastore}/content-ads/123/feedbacks/123")
      .to_return(body: "{}")
      data = SomeService.find(campaign_id: '123', id: '123')
      expect(data._proxy).to be_kind_of LHS::Item
    end

    it 'returns item in case of backend returning collection' do
      data = JSON.parse(load_json(:feedbacks))
      data['items'] = [data['items'].first]
      stub_request(:get, "#{datastore}/content-ads/123/feedbacks/123")
      .to_return(body: data.to_json)
      data = SomeService.find(campaign_id: '123', id: '123')
      expect(data._proxy).to be_kind_of LHS::Item
    end

    it 'fails when multiple items where found by parameters' do
      stub_request(:get, "#{datastore}/content-ads/123/feedbacks/123")
      .to_return(body: load_json(:feedbacks))
      expect(->{
        SomeService.find(campaign_id: '123', id: '123')
      }).to raise_error LHC::NotFound
    end

    it 'fails when no item as found by parameters' do
      data = JSON.parse(load_json(:feedbacks))
      data['items'] = []
      stub_request(:get, "#{datastore}/content-ads/123/feedbacks/123")
      .to_return(body: data.to_json)
      expect(->{
        SomeService.find(campaign_id: '123', id: '123')
      }).to raise_error LHC::NotFound
    end

    it 'raises if nothing was found with parameters' do
      stub_request(:get, "#{datastore}/content-ads/123/feedbacks/123")
        .to_return(status: 404)
      expect { SomeService.find(campaign_id: '123', id: '123') }.to raise_error LHC::NotFound
    end

  end
end
