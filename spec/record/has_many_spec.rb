require 'rails_helper'

describe LHS::Record do
  before(:each) do
    class Location < LHS::Record
      endpoint 'http://uberall/locations'
      endpoint 'http://uberall/locations/:id'
      has_many :listings
    end

    class Listing < LHS::Record

      def supported?
        true
      end
    end
  end

  context 'has_many' do
    let(:location) { Location.find(1) }
    let(:listing) { location.listings.first }

    it 'casts the relation into the correct type' do
      stub_request(:get, 'http://uberall/locations/1')
        .to_return(body:{
          listings: [{
            directory: { name: 'Instagram' }
          }]
        }.to_json)
      expect(listing).to be_kind_of(Listing)
      expect(listing.supported?).to eq true
    end
  end
end
