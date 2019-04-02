# frozen_string_literal: true

require 'active_support'

class LHS::Record

  module Tracing
    extend ActiveSupport::Concern

    module ClassMethods

      # Needs to be called directly from the first method (level) within LHS
      def trace!(options = {})
        (options || {}).tap do |options|
          options[:source] = caller[3]
        end
      end
    end
  end
end
