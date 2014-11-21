require 'singleton'
Dir[File.dirname(__FILE__) + '/concerns/service/*.rb'].each {|file| require file }

# A Service makes data available using multiple endpoints.
class LHS::Service
  include All
  include Batch
  include Build
  include Create
  include Endpoints
  include Find
  include FindBy
  include Mapping
  include Includes
  include Request
  include Singleton
  include Where
end
