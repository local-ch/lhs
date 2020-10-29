# frozen_string_literal: true

class DummyCustomer < Providers::CustomerSystem
  include SomeConcern
  endpoint 'http://customers'
  endpoint 'http://customers/{id}'
end
