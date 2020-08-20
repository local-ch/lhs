# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  before do
    class Place < LHS::Record
      endpoint 'http://datastore/places/{id}'
      endpoint 'http://datastore/users/{user_id}/places/{id}'

      def display_name
        "*#{name}*"
      end
    end

    class User < LHS::Record
      endpoint 'http://datastore/users/{id}'
    end

    stub_request(:get, 'http://datastore/users/123')
      .to_return(status: 200, body: {
        href: 'http://datastore/users/123',
        places: { href: 'http://datastore/users/123/places' }
      }.to_json)

    stub_request(:get, 'http://datastore/users/123/places?limit=100')
      .to_return(status: 200, body: {
        href: 'http://datastore/users/123/places?offset=0&limit=100',
        items: [
          {
            href: 'http://datastore/users/123/places/789'
          }, {
            href: 'http://datastore/users/123/places/790'
          }
        ],
        total: 2,
        offset: 0,
        limit: 10
      }.to_json)

    stub_request(:get, 'http://datastore/users/123/places/789')
      .to_return(
        body: {
          href: 'http://datastore/users/123/places/789?limit=100',
          name: 'Mc Donalds'
        }.to_json
      )

    stub_request(:get, 'http://datastore/users/123/places/790')
      .to_return(
        status: 404,
        body: {
          status: 404,
          message: 'The requested resource does not exist.'
        }.to_json
      )

  end

  let(:places) do
    User
      .includes(:places)
      .references(places: { ignore: LHC::NotFound })
      .find('123')
      .places
  end

  context '.compact' do
    it 'removes linked resouces which could not get fetched' do
      expect(places.compact.length).to eq 1
      expect(places.length).not_to eq 1 # leaves the original intact
    end
  end

  context 'record casting' do
    let(:expected_display_name) { '*Mc Donalds*' }

    it 'finds the right record class' do
      expect(places.first.display_name).to eq expected_display_name
      expect(places.compact.map(&:display_name)).to eq [expected_display_name]
    end
  end

  context '.compact!' do
    it 'removes linked resouces which could not get fetched' do
      expect(places.compact!.length).to eq 1
      expect(places.length).to eq 1 # and changes the original intact
    end
  end
end
