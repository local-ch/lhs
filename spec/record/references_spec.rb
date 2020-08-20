# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'references' do
    before do
      class Customer < LHS::Record
        endpoint 'http://datastore/customers/{id}'
      end

      class User < LHS::Record
        endpoint 'http://datastore/users/{id}'
        endpoint 'http://datastore/customers/{customer_id}/users/{id}'
        def reversed_name
          name.split.reverse.join(' ')
        end
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
          },
          'users' => {
            'href' => 'http://datastore/customers/1/users'
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
      { headers: { 'Authentication' => 'Bearer 123' } }
    end

    it 'uses the "references" hash for all symbols of the "including" array' do
      Customer
        .includes_first_page(:electronic_addresses, :contact_addresses)
        .references(
          electronic_addresses: referencing_options,
          contact_addresses: referencing_options
        )
        .find(1)
      assert_requested(electronic_addresses_request)
      assert_requested(contact_addresses_request)
    end

    describe 'mapping related classes correctly' do
      before do
        stub_request(:get, 'http://datastore/customers/1/users?limit=100').to_return(
          status: 200,
          body: {
            href: 'http://datastore/customers/1/users?offset=0&limit=100',
            items: [
              { href: 'http://datastore/customers/1/users/1' }
            ],
            total: 1,
            offset: 0,
            limit: 10
          }.to_json
        )

        stub_request(:get, 'http://datastore/customers/1/users/1')
          .with(headers: { 'Authentication' => 'Bearer 123' })
          .to_return(body: { href: 'http://datastore/users/1', name: 'Elizabeth Baker' }.to_json)
      end

      it 'maps correctly' do
        users = Customer
          .includes(:users)
          .references(users: referencing_options)
          .find(1)
          .users

        expect(users.first.reversed_name).to be_present
      end
    end

  end
end
