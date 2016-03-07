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

      def offset_key
        @configuration.try(:[], :offset) || :offset
      end
    end
  end
end
