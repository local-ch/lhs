# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  before do
    class Place < LHS::Record
      endpoint 'http://datastore/places/{id}'
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
          }
        ],
        total: 4,
        offset: 0,
        limit: 10
      }.to_json)

    stub_request(:get, 'http://datastore/users/123/places/789?limit=100')
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
      expect(places.compact.length).to eq 0
      expect(places.length).not_to eq 0 # leaves the original intact
    end
  end

  context '.compact!' do
    it 'removes linked resouces which could not get fetched' do
      expect(places.compact!.length).to eq 0
      expect(places.length).to eq 0 # and changes the original intact
    end
  end
end
