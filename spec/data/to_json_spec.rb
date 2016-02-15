require 'rails_helper'

describe LHS::Data do
  before(:each) do
    class Record < LHS::Record
      endpoint ':datastore/v2/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end

  let(:json) do
    load_json(:feedbacks)
  end

  let(:collection) do
    described_class.new(json, nil, Record)
  end

  let(:item) do
    collection[0]
  end

  it 'converts item to json' do
    expect(item.to_json)
      .to eq JSON.parse(load_json(:feedbacks))['items'].first.to_json
  end

  it 'converts collection to json' do
    expect(collection.to_json)
      .to eq JSON.parse(load_json(:feedbacks)).to_json
  end

  it 'converts link to json' do
    expect(item.campaign.to_json)
      .to eq item.campaign._raw.to_json
  end
end
