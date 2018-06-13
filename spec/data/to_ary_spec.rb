require 'rails_helper'

describe LHS::Data do
  before(:each) do
    class Record < LHS::Record
      endpoint '{+datastore}/v2/{campaign_id}/feedbacks'
      endpoint '{+datastore}/v2/feedbacks'
    end
  end

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    LHS::Data.new(json, nil, Record)
  end

  let(:item) do
    data[0]
  end

  it 'does not respond to to_ary' do
    expect(item.respond_to?(:to_ary)).to eq false
  end
end
