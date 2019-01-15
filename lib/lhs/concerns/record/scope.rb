# frozen_string_literal: true

require 'active_support'

class LHS::Record

  # Scopes allow you to reuse common where queries
  module Scope
    extend ActiveSupport::Concern

    module ClassMethods
      def scope(name, block)
        scopes[name] = block
        define_singleton_method(name) do |*args|
          block.call(*args)
        end
      end

      def scopes
        @scopes ||= {}
        @scopes
      end
    end
  end
end
