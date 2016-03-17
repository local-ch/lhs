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
    LHS::Data.new(json, nil, Record)
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
      .to eq JSON.parse(load_json(:feedbacks))['items'].to_json
  end

  it 'converts collection with options to json' do
    expect(collection.as_json(only: :href)).to eq [
      { "href" => "http://local.ch/v2/feedbacks/0sdaetZ-OWVg4oBiBJ-7IQ" },
      { "href" => "http://local.ch/v2/feedbacks/QsUOQWNJoB-GFUNsX7z0jg" },
      { "href" => "http://local.ch/v2/feedbacks/QynNtmpXlsEGvUJ0ekDKVw" },
      { "href" => "http://local.ch/v2/feedbacks/INmminYWNZwW_qNFx5peJQ" },
      { "href" => "http://local.ch/v2/feedbacks/ltgfr0VRYDN2nxyC119wTg" },
      { "href" => "http://local.ch/v2/feedbacks/5dUdQP-kZ6sulN8NtpGXTw" },
      { "href" => "http://local.ch/v2/feedbacks/Z3KfWzIEQ3ZVCUj2IdrSNQ" },
      { "href" => "http://local.ch/v2/feedbacks/ZUUUeiw-Stw5Zb1baHDUzQ" },
      { "href" => "http://local.ch/v2/feedbacks/GyeWvhEtU4cYN_5T2FX2UA" },
      { "href" => "http://local.ch/v2/feedbacks/o-qTRqQGFS3Z_RPJm1f8SA" }
    ]
  end

  it 'converts link to json' do
    expect(item.campaign.to_json)
      .to eq item.campaign._raw.to_json
  end

  context 'collections from arrays' do
    let(:collection) do
      LHS::Data.new([{ foo: 'foo', bar: 'bar' }])
    end

    it 'converts with options to json' do
      expect(collection.as_json(only: :foo)).to eq [{ 'foo' => 'foo' }]
      expect(collection.to_json(only: :foo)).to eq "[{\"foo\":\"foo\"}]"
    end
  end
end
