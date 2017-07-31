require 'active_support'

class LHS::Record

  # Allows configuring endpoints
  # like which keys are used for the items, offset, total etc.
  module Configuration
    extend ActiveSupport::Concern

    mattr_accessor :configuration

    module ClassMethods
      def configuration(args)
        @configuration = args.freeze || {}
      end

      def items_key
        symbolize_unless_complex(
          @configuration.try(:[], :items_key) || :items
        )
      end

      def item_created_key
        symbolize_unless_complex(
          @configuration.try(:[], :item_created_key)
        )
      end

      def limit_key
        symbolize_unless_complex(
          @configuration.try(:[], :limit_key) || :limit
        )
      end

      def total_key
        symbolize_unless_complex(
          @configuration.try(:[], :total_key) || :total
        )
      end

      # Key used for determine current page
      def pagination_key
        symbolize_unless_complex(
          @configuration.try(:[], :pagination_key) || :offset
        )
      end

      # Strategy used for calculationg next pages and navigate pages
      def pagination_strategy
        symbolize_unless_complex(
          @configuration.try(:[], :pagination_strategy) || :offset
        )
      end

      private

      def symbolize_unless_complex(value)
        return if value.blank?
        return value.to_sym unless value.is_a?(Array)
        value
      end
    end
  end
end
