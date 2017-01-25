require 'rails_helper'

describe LHS::Record do

  context 'references' do
    before(:each) do
      class Customer < LHS::Record
        endpoint 'http://datastore/customers/:id'
      end
    end

    let!(:customer_request) do
      stub_request(:get, "http://datastore/customers/1")
        .to_return(body: {
          'electronic_addresses' => {
            'href' => "http://datastore/electronic_addresses"
          },
          'contact_addresses' => {
            'href' => "http://datastore/contact_addresses"
          }
        }.to_json)
    end

    let!(:electronic_addresses_request) do
      stub_request(:get, "http://datastore/electronic_addresses")
        .with(referencing_options)
        .to_return(body: [].to_json)
    end

    let!(:contact_addresses_request) do
      stub_request(:get, "http://datastore/contact_addresses")
        .with(referencing_options)
        .to_return(body: [].to_json)
    end

    let(:referencing_options) do
      { headers: { 'Authentication': 'Bearer 123' } }
    end

    it 'uses the "references" hash for all symbols of the "including" array' do
      customer = Customer
        .includes(:electronic_addresses, :contact_addresses)
        .references(
          electronic_addresses: referencing_options,
          contact_addresses: referencing_options
        )
        .find(1)
      assert_requested(electronic_addresses_request)
      assert_requested(contact_addresses_request)
    end
  end
end
