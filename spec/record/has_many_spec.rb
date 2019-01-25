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
end
