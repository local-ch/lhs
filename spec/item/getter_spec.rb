require 'rails_helper'

describe LHS::Item do
  before(:each) do
    class Record < LHS::Record
      endpoint '{+datastore}/v2/{campaign_id}/feedbacks'
      endpoint '{+datastore}/v2/feedbacks'
    end
  end

  let(:data) do
    LHS::Data.new({ addresses: [{ business: { identities: [{ name: 'Löwenzorn' }] } }] }, nil, Record)
  end

  context 'item getter' do
    it 'returns a collection if you access an array' do
      expect(data.addresses).to be_kind_of(LHS::Data)
      expect(data.addresses._proxy).to be_kind_of(LHS::Collection)
      expect(data.addresses.first.business.identities.first.name).to eq 'Löwenzorn'
    end
  end
end
