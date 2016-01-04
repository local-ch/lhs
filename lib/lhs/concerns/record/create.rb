require 'active_support'

class LHS::Record

  module Create
    extend ActiveSupport::Concern

    module ClassMethods

      def create(data = {})
        create!(data)
        rescue LHC::Error => e
          json = JSON.parse(data.to_json)
          data = LHS::Data.new(json, nil, self, e.response.request)
          item = LHS::Item.new(data)
          item.errors = LHS::Errors.new(e.response)
          data._record_class.new(LHS::Data.new(item, data))
      end

      def create!(data = {})
        url = compute_url!(data)
        data = request(url: url, method: :post, body: data.to_json, headers: {'Content-Type' => 'application/json'})
        data._record_class.new(data)
      end
    end
  end
end
