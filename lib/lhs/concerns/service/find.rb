require 'active_support'

class LHS::Service

  module Find
    extend ActiveSupport::Concern

    module ClassMethods

      # Use find_by to fetch a single uniqe record.
      def find_by(params = {})
        endpoint = instance.find_endpoint(params)
        url = instance.inject(endpoint, params) + "/#{params.delete(:id)}"
        params = instance.remove_injected_params(params, endpoint)
        instance.merge_explicit_params!(params)
        request(
          url: url,
          method: :get,
          params: params
        )
      end

      private

      def request(params)
        request = LHS::Request.new(params)
        request.data
        rescue NotFound
          nil
      end
    end
  end
end
