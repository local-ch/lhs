# frozen_string_literal: true

require 'active_support'

class LHS::Record

  # Allows configuring endpoints
  # like which keys are used for the items, offset, total etc.
  module Configuration
    extend ActiveSupport::Concern

    mattr_accessor :configuration

    module ClassMethods
      def configuration(args)
        @configuration = args || {}
      end

      def auto_oauth?
        LHS.config.auto_oauth && @configuration && auto_oauth
      end

      def auto_oauth
        @configuration.fetch(:auto_oauth, false)
      end

      def oauth(provider = nil)
        value = provider || true
        @configuration.present? ? @configuration.merge!(auto_oauth: value) : configuration(auto_oauth: value)
      end

      def item_key
        symbolize_unless_complex(
          @configuration.try(:[], :item_key) || :item
        )
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

      def limit_key(type = nil)
        symbolize_unless_complex(
          pagination_parameter(@configuration.try(:[], :limit_key), type) ||
          :limit
        )
      end

      def total_key
        symbolize_unless_complex(
          @configuration.try(:[], :total_key) || :total
        )
      end

      # Key used for determine current page
      def pagination_key(type = nil)
        symbolize_unless_complex(
          pagination_parameter(@configuration.try(:[], :pagination_key), type) ||
          :offset
        )
      end

      # Strategy used for calculationg next pages and navigate pages
      def pagination_strategy
        symbolize_unless_complex(
          @configuration.try(:[], :pagination_strategy) || :offset
        )
      end

      # Allows record to be configured as not paginated,
      # as by default it's considered paginated
      def paginated
        return true if @configuration.blank?
        @configuration.fetch(:paginated, true)
      end

      private

      def symbolize_unless_complex(value)
        return if value.blank?
        return value.to_sym unless value.is_a?(Array)
        value
      end

      def pagination_parameter(configuration, type)
        return configuration unless configuration.is_a?(Hash)
        configuration[type]
      end
    end
  end
end
