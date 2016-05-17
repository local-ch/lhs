require 'rails_helper'

describe LHS::Record do
  context 'build' do
    let(:datastore) { 'http://local.ch/v2' }

    it 'is possible to load records twice' do
      class Feedback < LHS::Record
        endpoint ':datastore/feedbacks'
      end

      class Feedback < LHS::Record
        endpoint ':datastore/feedbacks'
      end
    end
  end
end
