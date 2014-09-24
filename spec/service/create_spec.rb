require 'rails_helper'

describe LHS::Service do

  context 'create' do

    before(:each) do
      class SomeService < LHS::Service
        endpoint ':datastore/v2/content-ads/:campaign_id/feedbacks'
        endpoint ':datastore/v2/feedbacks'
      end
    end

    let(:data) do
      {
        recommended: true,
        source_id: 'aaa'
      }
    end

    it 'creates new record on the backend' do
      stub_request(:post, 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks')
      .with(body: data.to_json)
      .to_return(status: 200, body: data.to_json)
      record = SomeService.create(data)
      expect(record.recommended).to eq true
      expect(record.errors).to eq nil
    end

    it 'uses proper endpoint when creating data' do
      stub_request(:post, 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/content-ads/12345/feedbacks')
      .with(body: data.to_json)
      .to_return(status: 200, body: data.to_json)
      SomeService.create(data.merge(campaign_id: '12345'))
    end
  end
end
