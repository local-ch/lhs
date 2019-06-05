# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do

  context 'endpoint priorities' do

    before do
      class Record < LHS::Record
        endpoint 'https://api/v2/feedbacks'
        endpoint 'https://api/v2/reviews'
        endpoint 'https://api/v2/streets/{id}'
        endpoint 'https://api/v2/feedbacks/{id}'
        endpoint 'https://api/v2/reviews/{id}'
      end
    end

    it 'always takes the first endpoint found' do
      stub_request(:get, "https://api/v2/feedbacks").to_return(status: 200)
      Record.fetch
      stub_request(:get, "https://api/v2/streets/1").to_return(status: 200)
      Record.find(1)
    end
  end
end
