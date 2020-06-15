# frozen_string_literal: true

class AutomaticAuthenticationController < ApplicationController

  def o_auth
    render json: {
      record: DummyRecordWithOauth.find(1).as_json,
      records: DummyRecordWithOauth.where(color: 'blue').as_json
    }
  end

  def o_auth_with_multiple_providers
    render json: {
      record: DummyRecordWithMultipleOauthProviders1.find(1).as_json,
      records: DummyRecordWithMultipleOauthProviders2.where(color: 'blue').as_json,
      per_endpoint: {
        record: DummyRecordWithMultipleOauthProvidersPerEndpoint.find(1).as_json,
        records: DummyRecordWithMultipleOauthProvidersPerEndpoint.where(color: 'blue').as_json
      }
    }
  end

  def o_auth_with_provider
    render json: {
      record: DummyRecordWithAutoOauthProvider.find(1).as_json,
      records: DummyRecordWithAutoOauthProvider.where(color: 'blue').as_json
    }
  end
end
