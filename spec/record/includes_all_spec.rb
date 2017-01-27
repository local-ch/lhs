require 'rails_helper'

describe LHS::Record do

  before(:each) do
    class Place < LHS::Record
      endpoint 'http://datastore/places/:id'
    end
  end

  let!(:place_request) do
    stub_request(:get, "http://datastore/places/1")
      .to_return(
        body: { 
          contracts: { href: 'http://datastore/places/1/contracts?limit=10&offset=0' }
        }.to_json
      )
  end

  let!(:contracts_requests) do
    stub_request(:get, "http://datastore/places/1/contracts?limit=999&offset=0")
      .to_return(
        body: { 
          products: { href: 'http://datastore/places/1/contracts?limit=10&offset=0' }
        }.to_json
      )
  end

  context 'includes all linked business objects' do

    it 'includes a resource' do
      favorite = Favorite.includes(:local_entry).find(1)
      expect(favorite.local_entry.company_name).to eq 'local.ch'
    end
