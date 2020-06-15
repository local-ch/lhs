# frozen_string_literal: true

require 'rails_helper'

describe 'Auto OAuth Authentication', type: :request, dummy_models: true do

  context 'without LHC::Auth interceptor enabled' do

    it 'shows a warning that it can not perform auto authentication' do
      expect(lambda do
        get '/automatic_authentication/oauth'
      end).to output(
        %r{\[WARNING\] Can't enable auto oauth as LHC::Auth interceptor is not enabled\/configured \(see https://github.com/local-ch/lhc/blob/master/README.md#authentication-interceptor\)!}
      ).to_stderr
    end
  end

  context 'with LHC::Auth interceptor enabled' do
    let(:token) { 'token-12345' }

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
        ).to_return(status: 200, body: { items: [ { name: 'Record' } ] }.to_json)
    end

    before do
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
      get '/automatic_authentication/oauth', params: { access_token: token }
      expect(record_request).to have_been_requested
      expect(records_request).to have_been_requested
    end

    it 'makes sure it does not reuse tokens from previous request threads' do
      allow(LHS::Interceptors::AutoOauth::ThreadRegistry).to receive(:access_token=).and_call_original
      expect(LHS::Interceptors::AutoOauth::ThreadRegistry).to receive(:access_token=).with nil
      
      get '/automatic_authentication/oauth', params: { access_token: token }
      expect(record_request).to have_been_requested
      expect(records_request).to have_been_requested
    end
  end
end
