require 'active_support'

class LHS::Service

  module Find
    extend ActiveSupport::Concern

    module ClassMethods

      # Use find a single uniqe record.
      def find(id)
        instance.request(id: id)
      end
    end
  end
end
