# frozen_string_literal: true

require 'rails_helper'

describe 'Auto OAuth Authentication', type: :request, dummy_models: true do

  context 'without LHC::Auth interceptor enabled' do

    before do
      LHS.configure do |config|
        config.auto_oauth = -> { access_token }
      end
    end

    it 'shows a warning that it can not perform auto authentication' do
      expect(lambda do
        get '/automatic_authentication/oauth'
      end).to output(
        %r{\[WARNING\] Can't enable auto oauth as LHC::Auth interceptor is not enabled\/configured \(see https://github.com/local-ch/lhc/blob/master/README.md#authentication-interceptor\)!}
      ).to_stderr
    end
  end

  context 'with LHC::Auth interceptor enabled' do

    context 'with only one auth provider' do

      let(:token) { ApplicationController::ACCESS_TOKEN }

      let(:record_request) do
        stub_request(:get, "http://datastore/v2/records_with_oauth/1")
          .with(
            headers: { 'Authorization' => "Bearer #{token}" }
          ).to_return(status: 200, body: { name: 'Record' }.to_json)
      end

      let(:records_request) do
        stub_request(:get, "http://datastore/v2/records_with_oauth?color=blue")
          .with(
            headers: { 'Authorization' => "Bearer #{token}" }
          ).to_return(status: 200, body: { items: [{ name: 'Record' }] }.to_json)
      end

      before do
        LHS.configure do |config|
          config.auto_oauth = -> { access_token }
        end
        LHC.configure do |config|
          config.interceptors = [LHC::Auth]
        end
        record_request
        records_request
      end

      after do
        LHC.config.reset
      end

      it 'applies OAuth credentials for the individual request automatically' do
        get '/automatic_authentication/oauth'
        expect(record_request).to have_been_requested
        expect(records_request).to have_been_requested
      end
    end

    context 'with multiple auth providers' do

      before do
        LHS.configure do |config|
          config.auto_oauth = proc do
            {
              provider1: access_token_provider_1,
              provider2: access_token_provider_2
            }
          end
        end
        LHC.configure do |config|
          config.interceptors = [LHC::Auth]
        end
        record_request_provider_1
        records_request_provider_2
        records_request_per_endpoint_provider_1
        record_request_per_endpoint_provider_2
      end

      let(:token) { ApplicationController::ACCESS_TOKEN }

      let(:record_request_provider_1) do
        stub_request(:get, "http://datastore/v2/records_with_multiple_oauth_providers_1/1")
          .with(
            headers: { 'Authorization' => "Bearer #{token}_provider_1" }
          ).to_return(status: 200, body: { name: 'Record' }.to_json)
      end

      let(:records_request_provider_2) do
        stub_request(:get, "http://datastore/v2/records_with_multiple_oauth_providers_2?color=blue")
          .with(
            headers: { 'Authorization' => "Bearer #{token}_provider_2" }
          ).to_return(status: 200, body: { items: [{ name: 'Record' }] }.to_json)
      end

      let(:records_request_per_endpoint_provider_1) do
        stub_request(:get, "http://datastore/v2/records_with_multiple_oauth_providers_per_endpoint?color=blue")
          .with(
            headers: { 'Authorization' => "Bearer #{token}_provider_1" }
          ).to_return(status: 200, body: { items: [{ name: 'Record' }] }.to_json)
      end

      let(:record_request_per_endpoint_provider_2) do
        stub_request(:get, "http://datastore/v2/records_with_multiple_oauth_providers_per_endpoint/1")
          .with(
            headers: { 'Authorization' => "Bearer #{token}_provider_2" }
          ).to_return(status: 200, body: { name: 'Record' }.to_json)
      end

      after do
        LHC.config.reset
      end

      it 'applies OAuth credentials for the individual request automatically no matter how many auth providers are configured ' do
        get '/automatic_authentication/oauth_with_multiple_providers'
        expect(record_request_provider_1).to have_been_requested
        expect(records_request_provider_2).to have_been_requested
        expect(records_request_per_endpoint_provider_1).to have_been_requested
        expect(record_request_per_endpoint_provider_2).to have_been_requested
      end
    end
  end
end
