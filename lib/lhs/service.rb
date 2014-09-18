require 'singleton'

# A Service makes data available using multiple endpoints.
class LHS::Service
  include Singleton
  include Endpoints

  # Used to query data from the service.
  def self.where(params = {})
    endpoint = instance.find_endpoint(params)
    url = instance.inject(endpoint, params)
    params = instance.remove_injected_params(params, endpoint)
    instance.merge_explicit_params!(params)
    request = LHS::Request.new(
      url: url,
      method: :get,
      params: params
    )
    request.data
  end
end
