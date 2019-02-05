# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do

  let(:listing) { location.listings.first }

  before do
    stub_request(:get, 'http://uberall/locations/1')
      .to_return(body: {
        listings: [{
          directory: { name: 'Instagram' }
        }]
      }.to_json)
  end

  context 'has_many' do

    before do
      class Location < LHS::Record
        endpoint 'http://uberall/locations'
        endpoint 'http://uberall/locations/{id}'
        has_many :listings
      end

      class Listing < LHS::Record

        def supported?
          true
        end
      end
    end

    let(:location) { Location.find(1) }

    it 'casts the relation into the correct type' do
      expect(listing).to be_kind_of(Listing)
      expect(listing.supported?).to eq true
    end

    it 'keeps hirachy when casting it to another class on access' do
      expect(listing._root._raw).to eq location._raw
      expect(listing.parent.parent._raw).to eq location._raw
    end
  end

  # TODO rename context
  context 'has_many v2' do
    before do
      class Place < LHS::Record
        endpoint 'https://datastore/places/{id}', followlocation: true, headers: { 'Prefer' => 'redirect-strategy=redirect-over-not-found' }
        has_many :available_assets
      end

      class AvailableAsset < LHS::Record
      end

      stub_request(:get, place_hash[:href])
        .to_return(body: place_hash.to_json)

      stub_request(:get, "http://datastore/places/#{place_id}/available-assets?limit=100")
        .to_return(body: {
          total: available_assets.size,
          items: available_assets
        }.to_json)
    end

    let(:place_id) { SecureRandom.urlsafe_base64 }

    let(:place_hash) do
      {
        href: "https://datastore/places/#{place_id}",
        id: place_id,
        available_assets: { href: "http://datastore/places/#{place_id}/available-assets?offset=0&limit=10" }
      }
    end

    let(:available_asset_hash) do
      { asset_code: 'OPENING_HOURS' }
    end

    let(:available_assets) { [available_asset_hash] }

    it 'has many available assets' do
      place = Place
        .options(auth: { bearer: 'XYZ' })
        .includes_all(:available_assets)
        .find(place_id)
      expect(place.available_assets.first).to be_a(AvailableAsset)
    end
  end

  context 'custom class_name' do

    before do
      module Uberall
        class Location < LHS::Record
          endpoint 'http://uberall/locations'
          endpoint 'http://uberall/locations/{id}'
          has_many :listings, class_name: 'Uberall::Listing'
        end
      end

      module Uberall
        class Listing < LHS::Record

          def supported?
            true
          end
        end
      end
    end

    let(:location) { Uberall::Location.find(1) }

    it 'casts the relation into the correct type' do
      expect(listing).to be_kind_of(Uberall::Listing)
      expect(listing.supported?).to eq true
    end

    it 'keeps hirachy when casting it to another class on access' do
      expect(listing._root._raw).to eq location._raw
      expect(listing.parent.parent._raw).to eq location._raw
    end
  end
end
