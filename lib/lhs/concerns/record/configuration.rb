require 'active_support'

class LHS::Record

  # Allows configuring endpoints
  # like which keys are used for the items, offset, total etc.
  module Configuration
    extend ActiveSupport::Concern

    mattr_accessor :configuration

    module ClassMethods
      def configuration(args)
        @configuration ||= args.freeze || {}
      end

      def items_key
        @configuration.try(:[], :items_key) || :items
      end

      def limit_key
        @configuration.try(:[], :limit_key) || :limit
      end

      def total_key
        @configuration.try(:[], :total_key) || :total
      end

      # Key used for determine current page
      def pagination_key
        @configuration.try(:[], :pagination_key) || :offset
      end

      # Strategy used for calculationg next pages and navigate pages
      def pagination_strategy
        @configuration.try(:[], :pagination_strategy) || :offset
      end
    end
  end
end
