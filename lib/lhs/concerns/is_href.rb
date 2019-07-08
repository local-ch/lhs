# frozen_string_literal: true

require 'active_support'

module LHS
  module IsHref
    extend ActiveSupport::Concern

    module ClassMethods

      def href?(input)
        input.is_a?(String) && %r{^https?://}.match(input).present?
      end
    end
  end
end
