# frozen_string_literal: true

module LHS::Problems
  module Nested
    class Warnings < LHS::Problems::Warnings
      include LHS::Problems::Nested::Base

      def initialize(warnings, scope)
        @raw = warnings.raw
        @messages = nest(warnings.messages, scope)
        @scope = scope
      end
    end
  end
end
