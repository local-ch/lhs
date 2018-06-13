require 'rails_helper'

describe LHS::Item do

  context 'make errors available' do

    before do
      class Presence < LHS::Record
        endpoint 'http://opm/presences'
      end
    end

    let(:place_href) { 'http://datastore/places/1' }

    it 'makes errors available no matter the response code' do
      stub_request(:post, "http://opm/presences")
        .to_return(
          status: 200,
          body: {
            place: { href: place_href },
            field_errors: [{
              code: 'REQUIRED_PROPERTY_VALUE',
              path: ['place', 'opening_hours']
            }]
          }.to_json
        )
      presence = Presence.create(place: { href: place_href })
      expect(presence.errors.any?).to be true
    end
  end
end
