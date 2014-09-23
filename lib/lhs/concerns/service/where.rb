require 'active_support'

class LHS::Service

  module Where
    extend ActiveSupport::Concern

    module ClassMethods

      # Used to query data from the service.
      def where(params = {})
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
  end
end
