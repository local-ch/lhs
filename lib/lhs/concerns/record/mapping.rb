# frozen_string_literal: true

require 'active_support'

class LHS::Record

  # Mapping allows to configure some accessors that access data using a provided proc
  module Mapping
    extend ActiveSupport::Concern

    module ClassMethods
      def mapping
        @mapping ||= {}
      end

      def mapping=(mapping)
        @mapping = mapping
      end

      def map(name, block)
        mapping[name] = block
      end
    end
  end
end
