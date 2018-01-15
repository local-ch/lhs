require 'rails_helper'

describe LHS::Record do
  context 'mapping' do
    let(:datastore) { 'http://local.ch/v2' }

    before(:each) do
      LHC.config.placeholder('datastore', datastore)
      class LocalEntry < LHS::Record
        endpoint '{+datastore}/local-entries'
        endpoint '{+datastore}/local-entries/{id}'
      end
    end

    it 'maps some attr accessors to another target (proxy)' do
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

    it 'maps for root_item even if that item is nested in a root collection' do
      class LocalEntry < LHS::Record
        def name
          addresses.first.business.identities.first.name
        end
      end
      stub_request(:get, "#{datastore}/local-entries/1?limit=1")
        .to_return(status: 200, body: { items: [{ addresses: [{ business: { identities: [{ name: 'Löwenzorn' }] } }] }] }.to_json)
      entry = LocalEntry.find_by(id: 1)
      expect(entry.name).to eq 'Löwenzorn'
    end

    it 'return data proxy in case of item or collection' do
      class LocalEntry < LHS::Record
        def business
          addresses.first.business
        end
      end
      stub_request(:get, "#{datastore}/local-entries/1")
        .to_return(status: 200, body: { addresses: [{ business: { identities: [{ name: 'Löwenzorn' }] } }] }.to_json)
      entry = LocalEntry.find(1)
      expect(entry.business).to be_kind_of LHS::Data
    end

    it 'clones mappings when using include' do
      class Agb < LHS::Record
        endpoint "{+datastore}/agbs/active?agb_type=CC_TOU"
        def pdf_url
          self['binary_url_pdf_de']
        end
      end

      preceding_agb_url = "#{datastore}/agbs/547f0b461c266c4830ea6cea"
      # initial request
      stub_request(:get, "#{datastore}/agbs/active?agb_type=CC_TOU&limit=1")
        .to_return(
          status: 200,
          body: {
            'href' => "#{datastore}/agbs/547f02c61c266c4830ea6ce7",
            'preceding_agb' => { 'href' => preceding_agb_url },
            'binary_url_pdf_de' => 'de'
          }.to_json
        )

      # includes request
      stub_request(:get, preceding_agb_url).to_return(
        status: 200, body: { 'href' => preceding_agb_url }.to_json, headers: {}
      )

      agb = Agb.includes(:preceding_agb).first!
      expect(agb.pdf_url).to be == 'de'
    end

    it 'makes mappings available even for nested data' do
      class LocalEntry < LHS::Record
        def name
          company_name
        end
      end
      class Favorite < LHS::Record
        endpoint '{+datastore}/favorites'
        endpoint '{+datastore}/favorites/{id}'
      end
      stub_request(:get, "#{datastore}/local-entries/1")
        .to_return(body: { company_name: 'local.ch' }.to_json)
      stub_request(:get, "#{datastore}/favorites/1")
        .to_return(body: { local_entry: { href: "#{datastore}/local-entries/1" } }.to_json)

      favorite = Favorite.includes(:local_entry).find(1)
      expect(favorite.local_entry).to be_kind_of LocalEntry
      expect(favorite.local_entry.name).to eq 'local.ch'
    end
  end
end
