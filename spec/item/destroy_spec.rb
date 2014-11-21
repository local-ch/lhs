require 'rails_helper'

describe LHS::Item do

  before(:each) do
    class SomeService < LHS::Service
      endpoint ':datastore/v2/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    LHS::Data.new(json, nil, SomeService)
  end

  let(:item) do
    data[0]
  end

  context 'destroy' do

    it 'destroys the item on the backend' do
      stub_request(:delete, "http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks/0sdaetZ-OWVg4oBiBJ-7IQ")
      .to_return(status: 200)
      expect(item.destroy._raw_).to eq item._raw_
    end
  end
end
