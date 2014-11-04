require 'rails_helper'

describe LHS::Service do

  context 'create' do

    let(:datastore) { 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2' }

    before(:each) do
      LHC.config.injection('datastore', datastore)
      class SomeService < LHS::Service
        endpoint ':datastore/content-ads/:campaign_id/feedbacks'
        endpoint ':datastore/feedbacks'
      end
    end

    let(:object) do
      {
        recommended: true,
        source_id: 'aaa'
      }
    end

    it 'creates new record on the backend' do
      stub_request(:post, "#{datastore}/feedbacks")
      .with(body: object.to_json)
      .to_return(status: 200, body: object.to_json)
      record = SomeService.create(object)
      expect(record.recommended).to eq true
      expect(record.errors).to eq nil
    end

    it 'uses proper endpoint when creating data' do
      stub_request(:post, "#{datastore}/content-ads/12345/feedbacks")
      .with(body: object.to_json)
      .to_return(status: 200, body: object.to_json)
      SomeService.create(object.merge(campaign_id: '12345'))
    end

    it 'merges backend response object with object' do
      body = object.merge(additional_key: 1)
      stub_request(:post, "#{datastore}/content-ads/12345/feedbacks")
      .with(body: object.to_json)
      .to_return(status: 200, body: body.to_json)
      data = SomeService.create(object.merge(campaign_id: '12345'))
      expect(data.additional_key).to eq 1
    end
  end
end
