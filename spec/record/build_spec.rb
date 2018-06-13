require 'rails_helper'

describe LHS::Record do
  context 'build' do
    let(:datastore) { 'http://local.ch/v2' }

    before do
      LHC.config.placeholder('datastore', datastore)
      class Feedback < LHS::Record
        endpoint '{+datastore}/content-ads/{campaign_id}/feedbacks'
        endpoint '{+datastore}/feedbacks'
      end
    end

    it 'builds a new item from scratch' do
      feedback = Feedback.build recommended: true
      expect(feedback).to be_kind_of Feedback
      expect(feedback.recommended).to eq true
      stub_request(:post, 'http://local.ch/v2/feedbacks')
        .with(body: "{\"recommended\":true}")
      feedback.save
    end
  end
end
