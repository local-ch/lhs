# frozen_string_literal: true

class DummyRecordWithMultipleOauthProviders2 < LHS::Record
  oauth(:provider2)
  endpoint 'http://datastore/v2/records_with_multiple_oauth_providers_2'
  endpoint 'http://datastore/v2/records_with_multiple_oauth_providers_2/{id}'
end
