require 'rails_helper'

describe LHS::Record do
  context 'includes all' do
    before(:each) do
      class Customer < LHS::Record
        endpoint 'http://datastore/customers/:id'
      end
    end

    let!(:customer_request) do
      stub_request(:get, 'http://datastore/customers/1')
        .to_return(
          body: {
            contracts: { href: 'http://datastore/customers/1/contracts' }
          }.to_json
        )
    end

    let!(:contracts_request) do
      stub_request(:get, "http://datastore/customers/1/contracts")
        .to_return(
          body: {
            products: { href: 'http://datastore/products' }
          }.to_json
        )
    end

    it 'includes all linked business objects no matter pagination' do
      customer = Customer
        .includes_all(contracts: :products)
        .find(1)
      customer.contracts
      expect(customer.contracts.length).to eq 33
      expect(customer.contracts.last).to eq last_contract
      expect(customer.contracts.first.products.length).to eq 22
      expect(customer.contracts.first.products.last).to eq last_product
    end
  end
end
