# frozen_string_literal: true

require 'rollbar_helper'

describe 'Extended Rollbar', type: :request do
  let!(:records_request_1) do
    stub_request(:get, "http://datastore/v2/records?color=blue").to_return(body: ['blue'].to_json)
  end

  let!(:records_request_2) do
    stub_request(:get, "http://datastore/v2/records?color=red").to_return(body: ['red'].to_json)
  end

  let!(:rollbar_request) do
    stub_request(:post, "https://api.rollbar.com/api/1/item/")
      .with do |request|
        json = JSON.parse request.body
        message = "Let's see if rollbar logs information about what kind of requests where made around here!"
        extra = {
          lhs: [
            {
              request: {
                params: { color: 'blue' },
                url: 'http://datastore/v2/records',
                headers: {
                  'Content-Type' => 'application/json; charset=utf-8',
                  'Accept' => 'application/json,application/vnd.api+json',
                  'Accept-Charset' => 'utf-8'
                }
              },
              response: { code: 200, body: '["blue"]' }
            }, {
              request: {
                params: { color: 'red' },
                url: 'http://datastore/v2/records',
                headers: {
                  'Content-Type' => 'application/json; charset=utf-8',
                  'Accept' => 'application/json,application/vnd.api+json',
                  'Accept-Charset' => 'utf-8'
                }
              },
              response: { code: 200, body: '["red"]' }
            }
          ].to_json
        }
        json['access_token'] == '12345' &&
          json['data']['level'] == 'error' &&
          json['data']['body']['trace']['exception']['message'] == message &&
          json['data']['body']['trace']['extra'].to_json == extra.to_json
      end
      .to_return(status: 200)
  end

  before do
    LHC.configure do |config|
      config.interceptors = [LHS::ExtendedRollbar]
    end
  end

  it 'extends default rollbar logging by adding information about the requests made during a request/response cycle',
  dummy_models: true do
    puts "BEFORE /extended_rollbar"
    get '/extended_rollbar'
    expect(records_request_1).to have_been_requested
    expect(records_request_2).to have_been_requested
    expect(rollbar_request).to have_been_requested
  end
end
