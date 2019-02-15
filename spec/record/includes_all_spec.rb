# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'includes all' do
    before do
      class Customer < LHS::Record
        endpoint 'http://datastore/customers/{id}'
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

    context 'links already contain pagination parameters' do
      let!(:customer_request) do
        stub_request(:get, 'http://datastore/customers/1')
          .to_return(
            body: {
              contracts: { href: 'http://datastore/customers/1/contracts?limit=5&offset=0' }
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

      it 'overwrites existing pagination paramters if they are already contained in a string' do
        expect(LHC).to receive(:request)
          .with(url: "http://datastore/customers/1").and_call_original

        expect(LHC).to receive(:request)
          .with(url: "http://datastore/customers/1/contracts",
                all: true,
                params: { limit: 100 }).and_call_original

        expect(LHC).to receive(:request)
          .with([{ url: "http://datastore/customers/1/contracts",
                   all: true,
                   params: { limit: 10, offset: 10 } },
                 { url: "http://datastore/customers/1/contracts",
                   all: true,
                   params: { limit: 10, offset: 20 } },
                 { url: "http://datastore/customers/1/contracts",
                   all: true,
                   params: { limit: 10, offset: 30 } }]).and_call_original

        customer = Customer
          .includes_all(:contracts)
          .find(1)
        expect(customer.contracts.length).to eq amount_of_contracts
      end
    end

    context 'includes for an empty array' do
      before do
        class Contract < LHS::Record
          endpoint 'http://datastore/contracts/{id}'
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
            -> { Contract.includes(:product).includes_all(:options).find(1) }
          ).not_to raise_error
          expect(
            -> { Contract.includes(:product).includes_all(:options).find(1, 2) }
          ).not_to raise_error
        end
      end

      context 'weird array without hrefs' do
        before do
          stub_request(:get, "http://datastore/options/1?limit=100")
            .to_return(body: { type: 'REACH_EXT' }.to_json)
        end

        let(:nested_resources) { [{ href: 'http://datastore/options/1' }, { type: 'E_COMMERCE' }] }

        it 'includes_all in case of an unexpect objects within array' do
          expect(
            -> { Contract.includes(:product).includes_all(:options).find(1) }
          ).not_to raise_error
          expect(
            -> { Contract.includes(:product).includes_all(:options).find(1, 2) }
          ).not_to raise_error
        end
      end
    end

    context 'include a known/identifiable record' do
      before do
        class Contract < LHS::Record
          endpoint 'http://datastore/contracts/{id}'
        end

        class Entry < LHS::Record
          endpoint '{+datastore}/entry/v1/{id}.json'
        end

        LHC.config.placeholder(:datastore, 'http://datastore')
      end

      let!(:customer_request) do
        stub_request(:get, %r{http://datastore/customers/\d+})
          .to_return(
            body: {
              contracts: [{ href: 'http://datastore/contracts/1' }, { href: 'http://datastore/contracts/2' }]
            }.to_json
          )
      end

      let!(:contracts_request) do
        stub_request(:get, %r{http://datastore/contracts/\d+})
          .to_return(
            body: {
              type: 'contract',
              entry: { href: 'http://datastore/entry/v1/1.json' }
            }.to_json
          )
      end

      let!(:entry_request) do
        stub_request(:get, %r{http://datastore/entry/v1/\d+.json})
          .to_return(
            body: {
              name: 'Casa Ferlin'
            }.to_json
          )
      end

      it 'loads included identifiable records without raising exceptions' do
        customer = Customer.includes_all(contracts: :entry).find(1, 2).first
        expect(customer.contracts.first.href).to eq 'http://datastore/contracts/1'
        expect(customer.contracts.first.type).to eq 'contract'
        expect(customer.contracts.first.entry.name).to eq 'Casa Ferlin'
      end
    end

    context 'includes all for parallel loaded ids' do
      before do
        class Place < LHS::Record
          endpoint 'http://datastore/places/{id}'
        end
      end

      let!(:place_request_1) do
        stub_request(:get, %r{http://datastore/places/1})
          .to_return(
            body: {
              category_relations: [
                { href: 'http://datastore/category_relations/1' },
                { href: 'http://datastore/category_relations/2' }
              ]
            }.to_json
          )
      end

      let!(:place_request_2) do
        stub_request(:get, %r{http://datastore/places/2})
          .to_return(
            body: {
              category_relations: []
            }.to_json
          )
      end

      let!(:place_request_3) do
        stub_request(:get, %r{http://datastore/places/3})
          .to_return(
            body: {
              category_relations: [
                { href: 'http://datastore/category_relations/1' },
                { href: 'http://datastore/category_relations/3' }
              ]
            }.to_json
          )
      end

      let!(:category_relation_request_1) do
        stub_request(:get, %r{http://datastore/category_relations/1})
          .to_return(
            body: {
              name: "Category 1"
            }.to_json
          )
      end

      let!(:category_relation_request_2) do
        stub_request(:get, %r{http://datastore/category_relations/2})
          .to_return(
            body: {
              name: "Category 2"
            }.to_json
          )
      end

      let!(:category_relation_request_3) do
        stub_request(:get, %r{http://datastore/category_relations/3})
          .to_return(
            body: {
              name: "Category 3"
            }.to_json
          )
      end

      let(:category_name) { 'Category Relation' }

      it 'requests places in parallel and includes category relation' do
        places = Place.includes_all(:category_relations).find(1, 2, 3)
        expect(places[0].category_relations[0].name).to eq 'Category 1'
        expect(places[0].category_relations[1].name).to eq 'Category 2'
        expect(places[2].category_relations[0].name).to eq 'Category 1'
        expect(places[2].category_relations[1].name).to eq 'Category 3'
      end
    end
  end

  context 'Linked resources' do
    before do
      stub_request(:get, 'http://datastore/places/1/contracts?offset=0&limit=10')
        .to_return(
          body: {
            href:  "http://datastore/v2/places/1/contracts?offset=0&limit=10",
            items: [{ href: "http://datastore/v2/contracts/1" }],
            offset: 0,
            limit: 10,
            total: 10
          }.to_json
        )

      stub_request(:get, "http://datastore/v2/contracts/1")
        .to_return(
          body: {
            customer: { name: 'Swisscom Directories AG' }
          }.to_json
        )

      stub_request(:get, 'http://datastore/places/1?limit=1')
        .to_return(
          body: { href: 'http://datastore/places/1', contracts: { href: 'http://datastore/places/1/contracts?offset=0&limit=10' } }.to_json
        )

      class Place < LHS::Record
        endpoint 'http://datastore/places/{id}'
      end

      class Contract < LHS::Record
        endpoint 'http://datastore/places/{place_id}/contracts'
      end
    end

    it 'does not use the root record endpoints when including nested records' do
      place = Place
        .includes_all(:contracts)
        .find_by(id: 1)
      expect(place.contracts.first.customer.name).to eq 'Swisscom Directories AG'
    end
  end

  context 'Linked single (unpaginated) resource' do
    before do
      stub_request(:get, "http://datastore/localEntry/v1/1.json?&limit=100")
        .to_return(
          body: {
            local_entry_id: '1'
          }.to_json
        )

      stub_request(:get, 'http://datastore/places/1?limit=1')
        .to_return(
          body: {
            href: 'http://datastore/places/1',
            local_entry: { href: 'http://datastore/localEntry/v1/1.json?&limit=100' }
          }.to_json
        )

      class Place < LHS::Record
        endpoint 'http://datastore/places/{id}'
      end

      class LocalEntry < LHS::Record
        endpoint 'http://datastore/localEntry/v1/{id}.json'
      end
    end

    it 'is not interpreted as collection (GREEN)' do
      place = Place
        .includes(:local_entry)
        .find_by(id: 1)
      expect(place.local_entry.local_entry_id).to eq '1'
    end

    it 'is not interpreted as collection (RED)' do
      place = Place
        .includes_all(:local_entry)
        .find_by(id: 1)
      expect(place.local_entry.local_entry_id).to eq '1'
    end
  end

  context 'nested includes_all' do
    context 'with optional children' do

      let(:favorites_request_stub) do
        stub_request(:get, %r{http://datastore/favorites})
          .to_return(
            body: {
              items: [{
                href: "http://datastore/favorites/1",
                place: {
                  href: "http://datastore/places/1"
                }
              }, {
                href: "http://datastore/favorite/2",
                place: {
                  href: "http://datastore/places/2"
                }
              }, {
                href: "http://datastore/favorite/3",
                place: {
                  href: "http://datastore/places/3"
                }
              }],
              total: 3,
              offset: 0,
              limit: 100
            }.to_json
          )
      end

      let(:place1_request_stub) do
        stub_request(:get, %r{http://datastore/places/1})
          .to_return(
            body: {
              href: "http://datastore/places/1",
              name: 'Place 1',
              contracts: {
                href: "http://datastore/places/1/contracts"
              }
            }.to_json
          )
      end

      let(:place2_request_stub) do
        stub_request(:get, %r{http://datastore/places/2})
          .to_return(
            body: {
              href: "http://datastore/places/2",
              name: 'Place 2'
            }.to_json
          )
      end

      let(:place3_request_stub) do
        stub_request(:get, %r{http://datastore/places/3})
          .to_return(
            body: {
              href: "http://datastore/places/3",
              name: 'Place 3',
              contracts: {
                href: "http://datastore/places/3/contracts"
              }
            }.to_json
          )
      end

      let(:contracts_request_for_place1_stub) do
        stub_request(:get, %r{http://datastore/places/1/contracts})
          .to_return(
            body: {
              items: [{
                href: "http://datastore/places/1/contracts/1",
                name: 'Contract 1'
              }],
              total: 1,
              offset: 0,
              limit: 10
            }.to_json
          )
      end

      let(:contracts_request_for_place3_stub) do
        stub_request(:get, %r{http://datastore/places/3/contracts})
          .to_return(
            body: {
              items: [{
                href: "http://datastore/places/3/contracts/1",
                name: 'Contract 3'
              }],
              total: 1,
              offset: 0,
              limit: 10
            }.to_json
          )
      end

      before do
        class Favorite < LHS::Record
          endpoint 'http://datastore/favorites'
        end

        class Place < LHS::Record
          endpoint 'http://datastore/places/{id}'
        end

        class Contract < LHS::Record
          endpoint 'http://datastore/places/{place_id}/contracts'
        end

        favorites_request_stub
        place1_request_stub
        place2_request_stub
        place3_request_stub
        contracts_request_for_place1_stub
        contracts_request_for_place3_stub
      end

      it 'includes nested objects when they exist' do
        favorites = Favorite.includes(:place).includes_all(place: :contracts).all

        expect(favorites.first.place.name).to eq('Place 1')
        expect(favorites.first.place.contracts.first.name).to eq('Contract 1')
      end

      it 'does not include nested objects when they are not there' do
        favorites = Favorite.includes(:place).includes_all(place: :contracts).all

        expect(favorites[1].place.name).to eq('Place 2')
        expect(favorites[1].place.contracts).to be(nil)
      end

      it 'does include and merges objects after nil objects in collections' do
        favorites = Favorite.includes(:place).includes_all(place: :contracts).all

        expect(favorites.last.place.name).to eq('Place 3')
        expect(favorites.last.place.contracts.first.name).to eq('Contract 3')
      end
    end
  end
end
