require 'rails_helper'

describe LHS::Record do
  let(:datastore) do
    'http://datastore/v2'
  end

  let(:response) do
    { body: [{ name: 'Steve' }] }
  end

  before do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint '{+datastore}/records/'
    end
  end

  context 'where values hash' do
    it 'provides the hash or where parameters that have been requested' do
      stub_request(:get, "http://datastore/v2/records/?available=true&color=blue").to_return(response)
      expect(
        Record.where(available: true).where(color: 'blue').where_values_hash
      ).to eq(available: true, color: 'blue')
      expect(
        Record.where(available: true, color: 'red').where(color: 'blue').where_values_hash
      ).to eq(available: true, color: 'blue')
    end
  end
end
