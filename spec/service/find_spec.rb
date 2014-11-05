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
      expect(->{ SomeService.find('not-existing') })
      .to raise_error LHC::NotFound
    end
  end
end
