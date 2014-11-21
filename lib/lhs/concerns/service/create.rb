require 'active_support'

class LHS::Service

  module Create
    extend ActiveSupport::Concern

    module ClassMethods

      # Create a new record.
      def create(data = {})
        url = instance.compute_url!(data)
        instance.request(url: url, method: :post, body: data.to_json, headers: {'Content-Type' => 'application/json'})
        rescue LHC::Error => e
          json = JSON.parse(data.to_json)
          data = LHS::Data.new(json, nil, self, e.response.request)
          item = LHS::Item.new(data, LHS::Errors.new(e.response))
          LHS::Data.new(item, data)
      end
    end
  end
end
