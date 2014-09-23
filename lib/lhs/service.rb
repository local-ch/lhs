require 'singleton'

# A Service makes data available using multiple endpoints.
class LHS::Service
  include Endpoints
  include FindBy
  include Singleton
  include Request
  include Where
end
