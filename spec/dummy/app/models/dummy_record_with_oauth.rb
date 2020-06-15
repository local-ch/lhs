# frozen_string_literal: true

class DummyRecordWithOauth < LHS::Record
  oauth
  endpoint 'http://datastore/v2/records_with_oauth'
  endpoint 'http://datastore/v2/records_with_oauth/{id}'
end
