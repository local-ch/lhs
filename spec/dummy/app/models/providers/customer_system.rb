module Providers

  class CustomerSystem < LHS::Record
    provider(headers: { 'Authorization': 'token123' })
  end

end
