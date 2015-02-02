require 'active_support'

class LHS::Service

  module First
    extend ActiveSupport::Concern

    module ClassMethods

      def first
        find_by
      end

      def first!
        find_by(raise_not_found: true)
      end
    end
  end
end
