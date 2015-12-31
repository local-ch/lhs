require 'active_support'

class LHS::Record

  module Where
    extend ActiveSupport::Concern

    module ClassMethods

      # Used to query data from the service.
      def where(params = {})
        request(params: params)
      end
    end
  end
end
