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

  context 'explicit association class configuration overrules href class casting' do
    before do
      class Place < LHS::Record
        endpoint 'http://places/places/{id}'
        has_many :categories, class_name: 'NewCategory'
      end

      class NewCategory < LHS::Record
        endpoint 'http://newcategories/newcategories/{id}'

        def name
          self['category_name']
        end
      end

      class Category < LHS::Record
        endpoint 'http://categories/categories/{id}'
      end

      stub_request(:get, "http://places/places/1")
        .to_return(body: {
          categories: [{
            href: 'https://categories/categories/1'
          }]
        }.to_json)

      stub_request(:get, "https://categories/categories/1")
        .to_return(body: {
          href: 'https://categories/categories/1',
          category_name: 'Pizza'
        }.to_json)
    end

    it 'explicit association configuration overrules href class casting' do
      place = Place.includes_first_page(:categories).find(1)
      expect(place.categories.first).to be_kind_of NewCategory
      expect(place.categories.first.name).to eq('Pizza')
    end
  end
end
