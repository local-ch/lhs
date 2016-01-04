require 'active_support'

class LHS::Record

  module Where
    extend ActiveSupport::Concern

    module ClassMethods

      # Used to query data from the service.
      def where(params = {})
        data = request(params: params)
        data._record_class.new(data)
      end
    end
  end
end
