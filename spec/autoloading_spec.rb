# frozen_string_literal: true

require "rails_helper"

describe LHS, type: :request do
  context 'autoloading' do
    it "pre/re-loads all LHS classes initialy,|
        because it's necessary for endpoint-to-record-class-discovery",
    reset_before: false do
      all_endpoints = LHS::Record::Endpoints.all
      expect(all_endpoints['http://datastore/v2/users']).to be_present
      expect(all_endpoints['http://datastore/v2/users/{id}']).to be_present
      expect(
        User.endpoints.detect { |endpoint| endpoint.url == 'http://datastore/v2/users' }
      ).to be_present
      expect(
        User.endpoints.detect { |endpoint| endpoint.url == 'http://datastore/v2/users/{id}' }
      ).to be_present
    end
  end
end
