require 'active_support'

class LHS::Service

  module Includes
    extend ActiveSupport::Concern

    module ClassMethods

      def including
        @including
      end

      def including=(including)
        @including = including
      end

      def includes(*args)
        class_clone = clone
        class_clone.endpoints = endpoints
        class_clone.mapping = mapping
        class_clone.including = args.size == 1 ? args[0] : args
        class_clone
      end
    end
  end
end
