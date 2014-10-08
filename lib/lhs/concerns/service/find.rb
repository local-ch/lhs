require 'active_support'

class LHS::Service

  module Find
    extend ActiveSupport::Concern

    module ClassMethods

      # Use find a single uniqe record.
      def find(id)
        url = instance.compute_url!(id: id)
        instance.request(url: url)
      end
    end
  end
end
