require 'active_support'

class LHS::Service

  module Create
    extend ActiveSupport::Concern

    module ClassMethods

      # Create a new record.
      def create(params = {})
        endpoint = instance.find_endpoint(params)
        url = instance.inject(endpoint, params)
        instance.remove_injected_params!(params, endpoint)
        instance.merge_explicit_params!(params)
        instance.request(url: url, method: :post, body: params.to_json)
        rescue LHS::Error => e
          json = JSON.parse(params.to_json)
          data = LHS::Data.new(json, nil, self, e.response.request)
          item = LHS::Item.new(data, LHS::Errors.new(e.response))
          LHS::Data.new(item, data)
      end
    end
  end
end
