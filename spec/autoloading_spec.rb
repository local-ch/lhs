require "rails_helper"

describe LHS, type: :request do
  context 'autoloading' do
    it "pre/re-loads all LHS classes initialy,|
        because it's necessary for endpoint-to-record-class-discovery",
    cleanup_before: false do
      all_endpoints = LHS::Record::Endpoints.all
      expect(all_endpoints['http://datastore/v2/users']).to be
      expect(all_endpoints['http://datastore/v2/users/:id']).to be
      expect(
        User.endpoints.detect { |endpoint| endpoint.url == 'http://datastore/v2/users' }
      ).to be
      expect(
        User.endpoints.detect { |endpoint| endpoint.url == 'http://datastore/v2/users/:id' }
      ).to be
    end
  end
end
