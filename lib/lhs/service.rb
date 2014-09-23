require 'singleton'

# A Service makes data available using multiple endpoints.
class LHS::Service
  include Endpoints
  include Find
  include Singleton
  include Where
end
