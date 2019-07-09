# frozen_string_literal: true

require 'active_support'

class LHS::Record

  module Pagination
    extend ActiveSupport::Concern
    # Kaminari-Interface
    delegate :current_page, :first_page, :last_page, :prev_page, :next_page, :limit_value, :total_pages, to: :_pagination

    def paginated?(raw = nil)
      self.class.paginated?(raw || _raw)
    end

    def _pagination
      self.class.pagination(_data)
    end

    module ClassMethods
      def pagination_class
        case pagination_strategy.to_sym
        when :page
          LHS::Pagination::Page
        when :start
          LHS::Pagination::Start
        when :link
          LHS::Pagination::Link
        else
          LHS::Pagination::Offset
        end
      end

      def pagination(data)
        pagination_class.new(data)
      end

      # Checks if given raw is paginated or not
      def paginated?(raw)
        raw.is_a?(Hash) && (
          raw.dig(*total_key).present? ||
          raw.dig(*limit_key(:body)).present?
        )
      end
    end
  end
end
