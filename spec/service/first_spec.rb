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

  context 'first' do

    it 'finds a single record' do
      stub_request(:get, "#{datastore}/feedbacks?limit=1").
      to_return(status: 200, body: load_json(:feedback))

      SomeService.first.source_id
    end

    it 'returns nil if no record was found' do
      stub_request(:get, "#{datastore}/feedbacks?limit=1").
      to_return(status: 404)
      expect(SomeService.first).to be_nil
    end
  end

  context 'first!' do

    it 'finds a single record' do
      stub_request(:get, "#{datastore}/feedbacks?limit=1").
      to_return(status: 200, body: load_json(:feedback))

      SomeService.first!.source_id
    end

    it 'raises LHC::NotFound if no record was found' do
      stub_request(:get, "#{datastore}/feedbacks?limit=1").
      to_return(status: 404)
      expect { SomeService.first! }.to raise_error LHC::NotFound
    end
  end
end
