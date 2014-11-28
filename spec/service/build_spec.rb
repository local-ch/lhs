require 'rails_helper'

describe LHS::Service do

  context 'new' do

    let(:datastore) { 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2' }

    before(:each) do
      LHC.config.placeholder('datastore', datastore)
      class Feedback < LHS::Service
        endpoint ':datastore/content-ads/:campaign_id/feedbacks'
        endpoint ':datastore/feedbacks'
      end
    end

    it 'builds a new item from scratch' do
      feedback = Feedback.build recommended: true
      expect(feedback.recommended).to eq true
      stub_request(:post, "http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks")
      .with(body: "{\"recommended\":true}")
      feedback.save
    end
  end
end
