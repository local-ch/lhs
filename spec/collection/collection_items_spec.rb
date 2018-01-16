require 'rails_helper'

describe LHS::Collection do
  let(:datastore) { 'http://local.ch/v2' }
  let(:items) { [{ name: 'Steve' }] }
  let(:collection) { Account.where }

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Account < LHS::Record
      endpoint '{+datastore}/accounts'
    end
    stub_request(:get, "http://local.ch/v2/accounts")
      .to_return(body: response_data.to_json)
  end

  context 'plain array' do
    let(:response_data) do
      items
    end

    it 'initalises a collection' do
      expect(collection.first.name).to eq 'Steve'
    end

    it 'casts items to be instance of defined LHS::Record' do
      expect(collection.first).to be_kind_of Account
    end
  end

  context 'items key' do
    let(:response_data) do
      {
        items: items
      }
    end

    it 'initalises a collection when reponse contains a key items containing an array of items' do
      expect(collection.first.name).to eq 'Steve'
    end
  end
end
