require 'rails_helper'

describe LHS::Record do
  context 'cast nested data' do
    let(:datastore) { 'http://local.ch/v2' }

    before(:each) do
      LHC.config.placeholder('datastore', datastore)
      class Customer < LHS::Record
        endpoint ':datastore/customers'
        endpoint ':datastore/customers/:id'
      end
      class Contract < LHS::Record
        endpoint ':datastore/contracts'
        endpoint ':datastore/contracts/:id'
      end
      class Address < LHS::Record
        endpoint ':datastore/addresses'
        endpoint ':datastore/addresses/:id'
      end
    end

    it 'casts nested data properly' do
      stub_request(:get, "http://local.ch/v2/customers?limit=1")
        .to_return(
          body: {
            items: [
              {
                href: "http://local.ch/v2/customers/12",
                address: {
                  href: "http://local.ch/v2/addresses/3"
                },
                contracts: [
                  {
                    href: "http://local.ch/v2/contracts/2"
                  }
                ]
              }
            ]
          }.to_json
        )
      customer = Customer.first
      expect(customer).to be_kind_of Customer
      expect(customer.address).to be_kind_of Address
      expect(customer.contracts.first).to be_kind_of Contract
    end
  end
end
