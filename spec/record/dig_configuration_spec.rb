require 'rails_helper'

describe LHS::Record do
  before(:each) do
    class Business < LHS::Record
      configuration items_key: [:response, :businesses], limit_key: [:response, :max], pagination_key: [:response, :offset], total_key: [:response, :count], pagination_strategy: :offset
      endpoint 'http://uberall/businesses'
    end
  end

  let(:stub_single_business_request) do
    stub_request(:get, "http://uberall/businesses?identifier=ABC123&limit=1")
      .to_return(body: {
        status: "SUCCESS",
        response: {
          offset: 0,
          max: 50,
          count: 1,
          businesses: [
            {
              identifier: 'ABC123',
              name: 'localsearch'
            }
          ]
        }
      }.to_json)
  end

  let(:stub_multiple_businesses_request) do
    stub_request(:get, "http://uberall/businesses?name=localsearch")
      .to_return(body: {
        status: "SUCCESS",
        response: {
          offset: 0,
          max: 50,
          count: 2,
          businesses: [
            {
              identifier: 'ABC123',
              name: 'localsearch'
            },
            {
              identifier: 'ABC121',
              name: 'Swisscom'
            }
          ]
        }
      }.to_json)
  end

  context 'access nested keys for configuration' do
    it 'uses paths from configuration to access nested values' do
      stub_single_business_request
      business = Business.find_by(identifier: 'ABC123')
      expect(business.identifier).to eq 'ABC123'
      expect(business.name).to eq 'localsearch'
    end

    it 'digs for meta data when meta information is nested' do
      stub_multiple_businesses_request
      businesses = Business.where(name: 'localsearch')
      expect(businesses.length).to eq 2
      expect(businesses.count).to eq 2
      expect(businesses.offset).to eq 0
    end
  end
end
