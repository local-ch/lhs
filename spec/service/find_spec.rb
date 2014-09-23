require 'rails_helper'

describe LHS::Service do

  before(:each) do
    class SomeService < LHS::Service
      endpoint ':datastore/v2/content-ads/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end

  context 'find' do

    it 'finds a single record' do
      stub_request(:get, "http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks/z12f-3asm3ngals").
      to_return(status: 200, body: load_json(:feedback))
      expect(
        SomeService.find_by(id: 'z12f-3asm3ngals').source_id
      ).to be_kind_of String
    end

    it 'returns nil if no record was found' do
      stub_request(:get, "http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks/something-inexistent").
      to_return(status: 404)
      expect(
        SomeService.find_by(id: 'something-inexistent')
      ).to eq nil
    end
  end
end
