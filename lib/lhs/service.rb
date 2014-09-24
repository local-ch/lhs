require 'singleton'

# A Service makes data available using multiple endpoints.
class LHS::Service
  include Create
  include Endpoints
  include Request
  include FindBy
  include Singleton
  include Where
end
