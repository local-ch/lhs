require 'active_support'

class LHS::Service

  module First
    extend ActiveSupport::Concern

    module ClassMethods

      def first
        find_by
      end
    end
  end
end
