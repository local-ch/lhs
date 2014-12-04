require 'rails_helper'

describe LHS::Service do

  context 'mapping' do

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

    it 'maps for root_item even if that item is nested in a root collection' do
      class LocalEntry < LHS::Service
        map :name, ->(entry){ entry.addresses.first.business.identities.first.name }
      end
      stub_request(:get, "#{datastore}/local-entries/1?limit=1")
      .to_return(status: 200, body: {items: [{addresses: [{business: {identities: [{name: 'Löwenzorn'}]}}]}]}.to_json)
      entry = LocalEntry.find_by(id: 1)
      expect(entry.name).to eq 'Löwenzorn'
    end

    it 'return data proxy in case of item or collection' do
      class LocalEntry < LHS::Service
        map :business, ->(entry){ entry.addresses.first.business }
      end
      stub_request(:get, "#{datastore}/local-entries/1")
      .to_return(status: 200, body: {addresses: [{business: {identities: [{name: 'Löwenzorn'}]}}]}.to_json)
      entry = LocalEntry.find(1)
      expect(entry.business).to be_kind_of LHS::Data
    end

    it 'mapping works with include' do
      class Agb < LHS::Service
        endpoint ":datastore/agbs/active?agb_type=CC_TOU"
        map :pdf_url, ->(agb) { agb['binary_url_pdf_de'] }
      end

      preceding_agb_url = "#{datastore}/agbs/547f0b461c266c4830ea6cea"
      # initial request
      stub_request(:get, "#{datastore}/agbs/active?agb_type=CC_TOU&limit=1").
      to_return(
        status: 200,
        body: {
          'href' => "#{datastore}/agbs/547f02c61c266c4830ea6ce7",
          'preceding_agb' => { 'href' => preceding_agb_url },
          'binary_url_pdf_de' => 'de'
        })
      # includes request
      stub_request(:get, preceding_agb_url).to_return(status: 200, body: '{}', headers: {})

      agb = Agb.includes(:preceding_agb).first!
      expect(agb.pdf_url).to be == 'de'
    end
  end
end
