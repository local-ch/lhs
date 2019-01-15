# frozen_string_literal: true

module LHS::Problems
  module Nested
    class Errors < LHS::Problems::Errors
      include LHS::Problems::Nested::Base

      def initialize(errors, scope)
        @raw = errors
        @messages = nest(errors.messages, scope)
        @message = errors.message
        @scope = scope
      end
    end
  end
end
