require 'rails_helper'

describe LHS::Record do
  before(:each) do
    class Location < LHS::Record
      configuration item_key: [:response, :location]
      endpoint 'http://uberall/location'
      endpoint 'http://uberall/location/:id'
    end
  end

  let(:json_body) do
    {
      response: {
        location: {
          id: 1
        }
      }
    }.to_json
  end

  let(:stub_request_by_id) do
    stub_request(:get, "http://uberall/location/1")
      .to_return(body: json_body)
  end

  let(:stub_request_by_get_parameters) do
    stub_request(:get, "http://uberall/location?identifier=1&limit=1")
      .to_return(body: json_body)
  end

  it 'uses configured item_key to unwrap response data for find' do
    stub_request_by_id
    location = Location.find(1)
    expect(location.id).to eq 1
  end

  it 'uses configured item_key to unwrap response data for find_by' do
    stub_request_by_get_parameters
    location = Location.find_by(identifier: 1)
    expect(location.id).to eq 1
  end
end
