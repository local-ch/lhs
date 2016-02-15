require 'rails_helper'

describe LHS::Record do

  context 'to_json' do
    let(:datastore) { 'http://local.ch/v2' }

    before(:each) do
      LHC.config.placeholder('datastore', datastore)
      class Feedback < LHS::Record
        endpoint ':datastore/feedbacks'
      end
    end

    it 'converts to json' do
      feedback = Feedback.new recommended: true
      expect(feedback.as_json).to eq(recommended: true)
      expect(feedback.to_json).to eq("{\"recommended\":true}")
    end
  end
end
