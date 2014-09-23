require 'active_support'

class LHS::Service

  module Create
    extend ActiveSupport::Concern

    module ClassMethods

      # Create a new record.
      def create(params = {})
        endpoint = instance.find_endpoint(params)
        url = instance.inject(endpoint, params)
        params = instance.remove_injected_params(params, endpoint)
        instance.merge_explicit_params!(params)
        request = instance.request(url: url, method: :post, body: params.to_json)
        request.data
      end
    end
  end
end
