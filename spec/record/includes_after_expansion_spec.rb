# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'includes records after expansion' do

    before do
      class User < LHS::Record
        endpoint 'http://users/{id}'
      end

      class Places < LHS::Record
        endpoint 'http://users/{id}/places'
        endpoint 'http://places/{id}'
      end

      class Contracts < LHS::Record
        endpoint 'http://places/{place_id}/contracts'
      end

      stub_request(:get, 'http://users/1')
        .to_return(
          body: {
            places: {
              href: 'http://users/1/places'
            }
          }.to_json
        )

      stub_request(:get, 'http://users/1/places?limit=100')
        .to_return(
          body: {
            items: [
              { href: 'http://places/345' }
            ],
            total: 1,
            offset: 0,
            limit: 10
          }.to_json
        )

      stub_request(:get, 'http://places/345')
        .to_return(
          body: {
            contracts: {
              href: "http://places/345/contracts?offset=0&limit=10"
            }
          }.to_json
        )

      stub_request(:get, 'http://places/345/contracts?offset=0&limit=10')
        .to_return(
          body: {
            items: [
              {
                product: { name: 'OPL' }
              }
            ]
          }.to_json
        )

    end

    it 'includes resources after expanding plain links' do
      user = User.includes(places: :contracts).find(1)
      expect(
        user.places.first.contracts.first.product.name
      ).to eq 'OPL'
    end
  end

  context 'with collections' do
    before do
      class User < LHS::Record
        endpoint 'http://users'
        endpoint 'http://users/{id}'
      end

      class Places < LHS::Record
        endpoint 'http://users/{id}/places'
        endpoint 'http://places/{id}'
      end

      stub_request(:get, 'http://users?email=user@example.com')
        .to_return(
          body: {
            href: 'http://users?email=user@example.com',
            items: [
              {
                places: {
                  href: 'http://users/1/places'
                }
              }
            ]
          }.to_json
        )

      stub_request(:get, 'http://users/1/places?limit=100')
        .to_return(
          body: {
            items: [
              {
                title: 'Place'
              }
            ],
            total: 0,
            offset: 0,
            limit: 10
          }.to_json
        )
    end

    it 'includes resources after expanding plain links' do
      user = User.includes(:places).find(email: 'user@example.com')
      expect(user.places.first.title).to eq 'Place'
    end
  end
end
