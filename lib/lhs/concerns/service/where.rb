require 'active_support'

class LHS::Service

  module Where
    extend ActiveSupport::Concern

    module ClassMethods

      # Used to query data from the service.
      def where(params = {})
        instance.request(params: params)
      end
    end
  end
end
