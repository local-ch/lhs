require 'rails_helper'

describe LHS::Record do
  before(:each) do
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

  context 'has_many' do
    let(:location) { Location.find(1) }
    let(:listing) { location.listings.first }

    before(:each) do
      stub_request(:get, 'http://uberall/locations/1')
        .to_return(body: {
          listings: [{
            directory: { name: 'Instagram' }
          }]
        }.to_json)
    end

    it 'casts the relation into the correct type' do
      expect(listing).to be_kind_of(Listing)
      expect(listing.supported?).to eq true
    end

    it 'keeps hirachy when casting it to another class on access' do
      expect(listing._root._raw).to eq location._raw
      expect(listing.parent.parent._raw).to eq location._raw
    end
  end
end
