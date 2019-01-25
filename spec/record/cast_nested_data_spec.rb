# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'cast nested data' do
    let(:stub_customer_request) do
      stub_request(:get, "https://datastore/customers?limit=1")
        .to_return(
          body: {
            items: [
              {
                href: "https://datastore/customers/12",
                address: {
                  href: "https://datastore/addresses/3"
                },
                contracts: [
                  {
                    href: "https://datastore/contracts/2"
                  }
                ]
              }
            ]
          }.to_json
        )
    end

    before do
      class Customer < LHS::Record
        endpoint 'https://datastore/customers'
        endpoint 'https://datastore/customers/{id}'
      end
      class Contract < LHS::Record
        endpoint 'https://datastore/contracts'
        endpoint 'https://datastore/contracts/{id}'
      end
      class Address < LHS::Record
        endpoint 'https://datastore/addresses'
        endpoint 'https://datastore/addresses/{id}', headers: { 'Authorization' => 'Bearer 123' }
      end
      stub_customer_request
    end

    it 'casts nested data properly' do
      customer = Customer.first
      expect(customer).to be_kind_of Customer
      expect(customer.address).to be_kind_of Address
      expect(customer.contracts.first).to be_kind_of Contract
    end

    context 'interact with nested resouce remotely' do
      let(:address_request_stub) do
        stub_request(:post, "https://datastore/addresses/3")
          .with(
            body: {
              href: 'https://datastore/addresses/3',
              zip: 8050
            }.to_json,
            headers: {
              'Authorization': 'Bearer 123'
            }
          )
          .to_return(status: 201)
      end

      before do
        address_request_stub
      end

      it 'applies casted records endpoint options to requests made to the nested resource' do
        customer = Customer.first
        address = customer.address
        address.zip = 8050
        address.save
      end
    end
  end
end
