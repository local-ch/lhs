# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  before do
    class Location < LHS::Record
      configuration item_key: [:response, :location]
      endpoint 'http://uberall/location'
      endpoint 'http://uberall/location/{id}'
    end
  end

  let(:location_response) do
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
      .to_return(body: location_response)
  end

  let(:stub_request_by_get_parameters) do
    stub_request(:get, "http://uberall/location?identifier=1&limit=1")
      .to_return(body: location_response)
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

  describe 'Holding on to request object' do
    let(:account_response) do
      { id: 1 }.to_json
    end

    let(:stub_location_by_id) do
      stub_request(:get, "http://uberall/location/1")
        .to_return(headers: { 'X-Custom-Header' => 'rspec' }, body: location_response)
    end

    let(:stub_account_by_id) do
      stub_request(:get, "http://yext/account/1")
        .to_return(headers: { 'X-Custom-Header' => 'rspec' }, body: account_response)
    end

    before do
      class Account < LHS::Record
        endpoint 'http://yext/account'
        endpoint 'http://yext/account/{id}'
      end

      stub_location_by_id
      stub_account_by_id
    end

    it 'preserves request object for nested items' do
      location = Location.find(1)
      expect(location._request).to be_present
    end

    it 'preserves request object for unnested items' do
      account = Account.find(1)
      expect(account._request).to be_present
    end
  end
end
