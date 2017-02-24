require 'rails_helper'

describe LHS::Record do
  context 'includes all' do
    before(:each) do
      class Customer < LHS::Record
        endpoint 'http://datastore/customers/:id'
      end
    end

    let(:amount_of_contracts) { 33 }
    let(:amount_of_products) { 22 }

    let!(:customer_request) do
      stub_request(:get, 'http://datastore/customers/1')
        .to_return(
          body: {
            contracts: { href: 'http://datastore/customers/1/contracts' }
          }.to_json
        )
    end

    let!(:contracts_request) do
      stub_request(:get, "http://datastore/customers/1/contracts?limit=100")
        .to_return(
          body: {
            items: 10.times.map do
              {
                products: { href: 'http://datastore/products' }
              }
            end,
            limit: 10,
            offset: 0,
            total: amount_of_contracts
          }.to_json
        )
    end

    def additional_contracts_request(offset, amount)
      stub_request(:get, "http://datastore/customers/1/contracts?limit=10&offset=#{offset}")
        .to_return(
          body: {
            items: amount.times.map do
              {
                products: { href: 'http://datastore/products' }
              }
            end,
            limit: 10,
            offset: offset,
            total: amount_of_contracts
          }.to_json
        )
    end

    let!(:contracts_request_page_2) do
      additional_contracts_request(10, 10)
    end

    let!(:contracts_request_page_3) do
      additional_contracts_request(20, 10)
    end

    let!(:contracts_request_page_4) do
      additional_contracts_request(30, 3)
    end

    let!(:products_request) do
      stub_request(:get, "http://datastore/products?limit=100")
        .to_return(
          body: {
            items: 10.times.map do
              { name: 'LBC' }
            end,
            limit: 10,
            offset: 0,
            total: amount_of_products
          }.to_json
        )
    end

    def additional_products_request(offset, amount)
      stub_request(:get, "http://datastore/products?limit=10&offset=#{offset}")
        .to_return(
          body: {
            items: amount.times.map do
              { name: 'LBC' }
            end,
            limit: 10,
            offset: offset,
            total: amount_of_products
          }.to_json
        )
    end

    let!(:products_request_page_2) do
      additional_products_request(10, 10)
    end

    let!(:products_request_page_3) do
      additional_products_request(20, 2)
    end

    it 'includes all linked business objects no matter pagination' do
      customer = Customer
        .includes_all(contracts: :products)
        .find(1)
      expect(customer.contracts.length).to eq amount_of_contracts
      expect(customer.contracts.first.products.length).to eq amount_of_products
      expect(customer_request).to have_been_requested.at_least_once
      expect(contracts_request).to have_been_requested.at_least_once
      expect(contracts_request_page_2).to have_been_requested.at_least_once
      expect(contracts_request_page_3).to have_been_requested.at_least_once
      expect(contracts_request_page_4).to have_been_requested.at_least_once
      expect(products_request).to have_been_requested.at_least_once
      expect(products_request_page_2).to have_been_requested.at_least_once
      expect(products_request_page_3).to have_been_requested.at_least_once
    end

    context 'includes for an empty array' do
      before(:each) do
        class Contract < LHS::Record
          endpoint 'http://datastore/contracts/:id'
        end
        stub_request(:get, %r{http://datastore/contracts/\d})
          .to_return(body: {
            options: nested_resources
          }.to_json)
      end

      context 'empty array' do
        let(:nested_resources) { [] }

        it 'includes_all in case of an empty array' do
          expect(
            ->{ Contract.includes(:product).includes_all(:options).find(1) }
          ).not_to raise_error
          expect(
            ->{ Contract.includes(:product).includes_all(:options).find(1, 2) }
          ).not_to raise_error
        end
      end

      context 'weird array without hrefs' do
        before(:each) do
          stub_request(:get, "http://datastore/options/1?limit=100")
            .to_return(body: { type: 'REACH_EXT' }.to_json)
        end

        let(:nested_resources) { [{ href: 'http://datastore/options/1' }, { type: 'E_COMMERCE' }] }

        it 'includes_all in case of an unexpect objects within array' do
          expect(
            ->{ Contract.includes(:product).includes_all(:options).find(1) }
          ).not_to raise_error
          expect(
            ->{ Contract.includes(:product).includes_all(:options).find(1, 2) }
          ).not_to raise_error
        end
      end
    end
  end
end
