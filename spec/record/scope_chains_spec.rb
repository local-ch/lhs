require 'rails_helper'

describe LHS::Record do
  let(:datastore) do
    'http://datastore/v2'
  end

  let(:response) do
    { body: [{ name: 'Steve' }] }
  end

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint ':datastore/records/'
      scope :blue, -> { where(color: 'blue') }
      scope :available, -> { where(availalbe: 'true') }
      scope :limited_to, ->(limit) { where(limit: limit) }
    end
  end

  context 'scope chains' do
    it 'allows chaining multiple scopes' do
      stub_request(:get, "http://datastore/v2/records/?availalbe=true&color=blue&limit=20").to_return(response)
      expect(
        Record.blue.available.limited_to(20).first.name
      ).to eq 'Steve'
    end

    it 'allows to chain multiple scopes when first one has arguments' do
      stub_request(:get, "http://datastore/v2/records/?availalbe=true&color=blue&limit=20").to_return(response)
      expect(
        Record.limited_to(20).blue.available.first.name
      ).to eq 'Steve'
    end
  end
end
