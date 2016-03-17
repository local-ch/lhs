require 'rails_helper'

describe LHS::Data do
  before(:each) do
    class Record < LHS::Record
      endpoint ':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks'
      endpoint ':datastore/v2/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end


  context 'raw' do
    let(:data) do
      LHS::Data.new({ href: 'http://www.local.ch/v2/stuff', id: '123123123' }, nil, Record)
    end

    it 'you can access raw data that is underlying' do
      expect(data._raw).to be_kind_of Hash
    end

    it 'returns a hash with symoblized keys' do
      expect(data._raw.keys.first).to be_kind_of Symbol
    end

    context 'data_from_item' do
      let(:data) do
        raw = { href: 'http://www.local.ch/v2/stuff' }
        item = LHS::Item.new(LHS::Data.new(raw, nil, Record))
        LHS::Data.new(item)
      end

      it 'forwards raw when you feed data with some LHS object' do
        expect(data._raw).to be_kind_of Hash
        expect(data._raw).to eq(
          href: 'http://www.local.ch/v2/stuff'
        )
      end
    end
  end
end
