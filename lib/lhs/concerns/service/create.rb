require 'active_support'

class LHS::Service

  module Create
    extend ActiveSupport::Concern

    module ClassMethods

      # Create a new record.
      def create(params = {})
        instance.request(params.merge(method: :post))
        rescue LHC::Error => e
          json = JSON.parse(params.to_json)
          data = LHS::Data.new(json, nil, self, e.response.request)
          item = LHS::Item.new(data, LHS::Errors.new(e.response))
          LHS::Data.new(item, data)
      end
    end
  end
end
