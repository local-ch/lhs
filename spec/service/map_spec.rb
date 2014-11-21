require 'rails_helper'

describe LHS::Service do

  context 'map' do

    let(:datastore) { 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2' }

    before(:each) do
      LHC.config.placeholder('datastore', datastore)
      class LocalEntry < LHS::Service
        endpoint ':datastore/local-entries'
      end
    end

    it 'maps some attr accessors to another target (proxy)' do
      class LocalEntry < LHS::Service
        map :name, ->(entry){ entry.addresses.first.business.identities.first.name }
      end
      stub_request(:get, "#{datastore}/local-entries/1")
      .to_return(status: 200, body: {addresses: [{business: {identities: [{name: 'Löwenzorn'}]}}]}.to_json)
      entry = LocalEntry.find(1)
      expect(entry.name).to eq 'Löwenzorn'
    end
  end
end
