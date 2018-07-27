require 'rails_helper'

describe LHS::Record do

  context 'last' do

    context 'for not paginated endpoints' do

      before do
        class Sector < LHS::Record
          endpoint 'http://services/sectors'
        end

        stub_request(:get, "http://services/sectors?limit=1")
          .to_return(
            body: [{ number: 1 }, { number: 2 }, { number: 3 }].to_json
          )
      end

      it 'returns the last record from the already complete collection' do
        sector = Sector.last
        expect(sector).to be_kind_of Sector
        expect(sector.number).to eq 3
      end
    end

    context 'for paginated endpoints' do

      before do
        class Place < LHS::Record
          endpoint 'http://datastore/places'
        end

        stub_request(:get, "http://datastore/places?limit=1")
          .to_return(
            body: {
              items: [
                { id: 'first-1', company_name: 'Localsearch AG' }
              ],
              total: 500,
              limit: 1,
              offset: 0
            }.to_json
          )

        stub_request(:get, "http://datastore/places?limit=1&offset=499")
          .to_return(
            body: {
              items: [
                { id: 'last-500', company_name: 'Curious GmbH' }
              ],
              total: 500,
              limit: 1,
              offset: 0
            }.to_json
          )
      end

      it 'returns the last record from the already complete collection' do
        place = Place.last
        expect(place).to be_kind_of Place
        expect(place.id).to eq 'last-500'
      end
    end
  end
end
