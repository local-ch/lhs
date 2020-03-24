# frozen_string_literal: true

class DummyUser < LHS::Record
  endpoint 'http://datastore/v2/users'
  endpoint 'http://datastore/v2/users/{id}'
end
