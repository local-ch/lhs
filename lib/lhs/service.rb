Dir[File.dirname(__FILE__) + '/concerns/service/*.rb'].each {|file| require file }

# A Service makes data available by using backend endpoints.
class LHS::Service
  include All
  include Batch
  include Build
  include Create
  include Endpoints
  include Find
  include FindBy
  include First
  include Mapping
  include Model
  include Includes
  include Request
  include Where
end
