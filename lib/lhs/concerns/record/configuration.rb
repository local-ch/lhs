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
        @configuration.try(:[], :items) || :items
      end

      def limit_key
        @configuration.try(:[], :limit) || :limit
      end

      def total_key
        @configuration.try(:[], :total) || :total
      end

      # Key used for determine current page
      def pagination_key
        @configuration.try(:[], :pagination_key) || :offset
      end

      # Type used for calculationg next pages and navigate pages
      def pagination_type
        @configuration.try(:[], :pagination_type) || :offset
      end
    end
  end
end
