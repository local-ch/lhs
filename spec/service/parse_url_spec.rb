require 'rails_helper'

describe LHS::Service do

  context 'parse_url' do

    it 'parses strings as an endpoint url and injects route parameters' do
      expect(
        LHS::Service.instance.parse_url(':datastore/v2/content-ads/:campaign_id/feedbacks', campaign_id: '12345')
      ).to eq 'datastore-stg.lb-service/v2/content-ads/12345/feedbacks'
    end

  end

end
