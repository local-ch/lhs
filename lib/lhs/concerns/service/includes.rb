require 'active_support'

class LHS::Service

  module Includes
    extend ActiveSupport::Concern

    attr_accessor :includes

    module ClassMethods

      def includes(*args)
        class_clone = clone
        class_clone.instance.endpoints = instance.endpoints
        class_clone.instance.mapping = instance.mapping
        class_clone.instance.includes = args.size == 1 ? args[0] : args
        class_clone
      end
    end
  end
end
