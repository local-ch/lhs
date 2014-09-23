require 'active_support'

class LHS::Service

  module FindBy
    extend ActiveSupport::Concern

    module ClassMethods

      # Use find_by to fetch a single uniqe record.
      def find_by(params = {})
        endpoint = instance.find_endpoint(params)
        url = instance.inject(endpoint, params)
        url +=  "/#{params.delete(:id)}" if params[:id]
        params = instance.remove_injected_params(params, endpoint)
        instance.merge_explicit_params!(params)
        request = instance.request(url: url, method: :get, params: params)
        data = request.data
        if data._proxy_.is_a?(LHS::Collection)
          data.first
        else
          data
        end
        rescue NotFound
          nil
      end
    end
  end
end
