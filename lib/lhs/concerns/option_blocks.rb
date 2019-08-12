# frozen_string_literal: true

require 'active_support'

module LHS
  module OptionBlocks
    extend ActiveSupport::Concern

    class CurrentOptionBlock
      # Using ActiveSupports PerThreadRegistry to be able to support Active Support v4.
      # Will switch to thread_mattr_accessor (which comes with Activesupport) when we dropping support for Active Support v4.
      extend ActiveSupport::PerThreadRegistry
      attr_accessor :options
    end

    module ClassMethods
      def options(options, &block)
        CurrentOptionBlock.options = options
        block.call
      ensure
        CurrentOptionBlock.options = nil
      end
    end
  end
end
