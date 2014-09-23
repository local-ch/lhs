require 'rails_helper'

describe LHS::Service do

  context 'create' do

    before(:each) do
      class SomeService < LHS::Service
        endpoint ':datastore/v2/:campaign_id/feedbacks'
        endpoint ':datastore/v2/feedbacks'
      end
    end

    it 'creates new record on the backend' do
      data = {
        recommended: true,
        source_id: 'aaa',
        content_ad_id: '1z-5r1fkaj'
      }
      stub_request(:post, "http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks").
      with(body: data.to_json)
      .to_return(status: 200, body: data.to_json)
      data = SomeService.create(data)
      expect(data.recommended).to eq true
    end
  end
end
