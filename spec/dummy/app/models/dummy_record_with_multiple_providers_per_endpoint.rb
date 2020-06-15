# frozen_string_literal: true

class DummyRecordWithMultipleOauthProvidersPerEndpoint < LHS::Record
  endpoint 'http://datastore/v2/records_with_multiple_oauth_providers_per_endpoint', oauth: :provider1
  endpoint 'http://datastore/v2/records_with_multiple_oauth_providers_per_endpoint/{id}', oauth: :provider2
end
