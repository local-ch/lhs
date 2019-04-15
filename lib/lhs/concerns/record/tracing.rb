# frozen_string_literal: true

require 'active_support'

class LHS::Record

  module Tracing
    extend ActiveSupport::Concern

    module ClassMethods
      # Needs to be called directly from the first method (level) within LHS
      def trace!(options = {})
        return options unless Rails.logger.level == 0

        (options || {}).tap do |options|
          source = caller.detect do |source|
            !source.match?(%r{/lib/lhs})
          end
          options[:source] = source
        end
      end
    end
  end
end
