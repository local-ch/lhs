require 'rails_helper'
require 'webrick'

describe LHS::Record do

  before do
    class Location < LHS::Record
      endpoint 'http://uberall/locations'
      configuration(
        limit_key: { body: %i[response max], parameter: :max },
        pagination_key: { body: %i[response offset], parameter: :offset },
        total_key: %i[response count],
        items_key: %i[response locations],
        pagination_strategy: :offset
      )
    end
  end

  context 'explicit pagination parameters for retrieving pages' do

    it 'uses explicit parameters when retrieving pages' do
      stub_request(:get, "http://uberall/locations?max=100")
        .to_return(body: {
          response: {
            locations: 10.times.map { |_| { name: WEBrick::Utils.random_string(10) } },
            max: 10,
            offset: 0,
            count: 30
          }
        }.to_json)

      stub_request(:get, "http://uberall/locations?max=10&offset=10")
        .to_return(body: {
          response: {
            locations: 10.times.map { |_| { name: WEBrick::Utils.random_string(10) } },
            max: 10,
            offset: 10,
            count: 30
          }
        }.to_json)

      stub_request(:get, "http://uberall/locations?max=10&offset=20")
        .to_return(body: {
          response: {
            locations: 10.times.map { |_| { name: WEBrick::Utils.random_string(10) } },
            max: 10,
            offset: 20,
            count: 30
          }
        }.to_json)

      locations = Location.all.fetch
      expect(locations.length).to eq 30
      expect(locations.count).to eq 30
      expect(locations.offset).to eq 20
      expect(locations.limit).to eq 10
    end
  end
end
