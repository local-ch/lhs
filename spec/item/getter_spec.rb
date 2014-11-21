require 'rails_helper'

describe LHS::Item do

  let(:data) do
    LHS::Data.new({addresses: [{business: {identities: [{name: 'Löwenzorn'}]}}]})
  end

  context 'item getter' do

    it 'returns a collection if you access an array' do
      expect(data.addresses).to be_kind_of(LHS::Data)
      expect(data.addresses._proxy_).to be_kind_of(LHS::Collection)
      expect(data.addresses.first.business.identities.first.name).to eq 'Löwenzorn'
    end
  end
end
