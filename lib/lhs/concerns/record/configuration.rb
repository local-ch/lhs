require 'active_support'

class LHS::Record

  # Allows configuring endpoints
  # like which keys are used for the items, offset, total etc.
  module Configuration
    extend ActiveSupport::Concern

    DEFAULT_ITEMS_KEY = :items

    mattr_accessor :configuration

    module ClassMethods
      def configuration(args)
        @configuration = args.freeze || {}
      end

      def items_key
        (@configuration.try(:[], :items_key) || DEFAULT_ITEMS_KEY).to_sym
      end

      def limit_key
        (@configuration.try(:[], :limit_key) || :limit).to_sym
      end

      def total_key
        (@configuration.try(:[], :total_key) || :total).to_sym
      end

      # Key used for determine current page
      def pagination_key
        (@configuration.try(:[], :pagination_key) || :offset).to_sym
      end

      # Strategy used for calculationg next pages and navigate pages
      def pagination_strategy
        (@configuration.try(:[], :pagination_strategy) || :offset).to_sym
      end
    end
  end
end
