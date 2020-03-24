# frozen_string_literal: true

class Customer < Providers::CustomerSystem
  endpoint 'http://customers'
  endpoint 'http://customers/{id}'
end
