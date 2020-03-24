# frozen_string_literal: true

class DummyCustomer < Providers::CustomerSystem
  endpoint 'http://customers'
  endpoint 'http://customers/{id}'
end
