require 'active_support'

class LHS::Record

  module First
    extend ActiveSupport::Concern

    module ClassMethods

      def first
        find_by
      end

      def first!
        find_by!
      end
    end
  end
end
