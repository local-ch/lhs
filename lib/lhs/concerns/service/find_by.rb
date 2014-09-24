require 'active_support'

class LHS::Service

  module FindBy
    extend ActiveSupport::Concern

    module ClassMethods

      # Use find_by to fetch a single uniqe record.
      def find_by(params = {})
        data = instance.request(params)
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
