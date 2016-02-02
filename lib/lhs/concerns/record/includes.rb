require 'active_support'

class LHS::Record

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
        name = "#{self}#{args.object_id}"
        constant = Object.const_set(name, self)
        class_clone = constant
        class_clone.endpoints = endpoints
        class_clone.mapping = mapping
        class_clone.including = args.size == 1 ? args[0] : args
        class_clone
      end
    end
  end
end
