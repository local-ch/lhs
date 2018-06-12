require 'rails_helper'

describe LHS::Record do
  context 'definitions' do
    let(:datastore) { 'http://local.ch/v2' }

    before do
      LHC.config.placeholder('datastore', datastore)
      class LocalEntry < LHS::Record
        endpoint '{+datastore}/local-entries'
        endpoint '{+datastore}/local-entries/{id}'
      end
    end

    it 'allows mappings in all functions/defitions' do
      class LocalEntry < LHS::Record
        def name
          addresses.first.business.identities.first.name
        end
      end
      stub_request(:get, "#{datastore}/local-entries/1")
        .to_return(status: 200, body: { addresses: [{ business: { identities: [{ name: 'Löwenzorn' }] } }] }.to_json)
      entry = LocalEntry.find(1)
      expect(entry.name).to eq 'Löwenzorn'
    end
  end
end
