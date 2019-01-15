# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  before do
    class Record < LHS::Record
      endpoint 'http://datastore/records'
      endpoint 'http://datastore/records/{id}'
    end
  end

  let(:json) do
    { id: 1, name: 'Steve' }.to_json
  end

  context 'reload!' do
    it 'returns an instance of the record, not an LHS::Item' do
      stub_request(:post, "http://datastore/records").to_return(body: json)
      stub_request(:get, "http://datastore/records/1").to_return(body: json)
      record = Record.create!(name: 'Steve')
      expect(record).to be_kind_of Record
      expect(record.reload!).to be_kind_of Record
    end
  end

  context 'nested items' do

    before do
      class Location < LHS::Record
        endpoint 'http://uberall/locations'
        endpoint 'http://uberall/locations/{id}'

        configuration item_key: [:response, :location], items_key: [:response, :locations]
      end
    end

    it 'merges reloads properly' do
      stub_request(:get, "http://uberall/locations?identifier=http://places/1&limit=1")
        .to_return(
          body: {
            response: {
              locations: [{
                id: 1,
                name: 'Fridolin'
              }]
            }
          }.to_json
        )
      location = Location.find_by(identifier: 'http://places/1')
      stub_request(:get, "http://uberall/locations/1")
        .to_return(
          body: {
            response: {
              location: {
                normalizationStatus: 'NORMALIZED'
              }
            }
          }.to_json
        )
      location.reload!
      expect(location.normalizationStatus).to eq 'NORMALIZED'
    end
  end
end
