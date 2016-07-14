require 'rails_helper'

describe LHS::Data do
  before(:each) do
    class Record < LHS::Record
      endpoint ':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks'
      endpoint ':datastore/v2/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end

  let(:data_from_raw) do
    LHS::Data.new({ href: 'http://www.local.ch/v2/stuff', id: '123123123' }, nil, Record)
  end

  let(:data_from_item) do
    raw = { href: 'http://www.local.ch/v2/stuff' }
    item = LHS::Item.new(LHS::Data.new(raw, nil, Record))
    LHS::Data.new(item)
  end

  let(:data_from_array) do
    LHS::Data.new([
      { href: 'http://www.local.ch/v2/stuff/3', id: '123123123' },
      { href: 'http://www.local.ch/v2/stuff/4', id: '123123124' }
    ].to_json)
  end

  context 'raw' do
    it 'you can access raw data that is underlying' do
      expect(data_from_raw._raw).to be_kind_of Hash
    end

    it 'forwards raw when you feed data with some LHS object' do
      expect(data_from_item._raw).to be_kind_of Hash
      expect(data_from_item._raw[:href]).to eq(
        'http://www.local.ch/v2/stuff'
      )
    end

    it 'returns a Hash with symbols when the input is an array' do
      expect(data_from_array._raw).to be_kind_of Array
      expect(data_from_array._raw.first.keys.first).to be_kind_of Symbol
    end
  end
end
