require 'active_support'

class LHS::Service

  module First
    extend ActiveSupport::Concern

    module ClassMethods

      def first
        find_by
      end

      def first!
        result = find_by(raise_not_found: true)
        fail LHC::NotFound unless result
        result
      end
    end
  end
end
