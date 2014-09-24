require 'singleton'
Dir[File.dirname(__FILE__) + '/concerns/service/*.rb'].each {|file| require file }

# A Service makes data available using multiple endpoints.
class LHS::Service
  include All
  include Create
  include Endpoints
  include Request
  include Find
  include FindBy
  include Singleton
  include Where
end
