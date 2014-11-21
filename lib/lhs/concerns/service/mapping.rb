require 'active_support'

class LHS::Service

  # Mapping allows to configure some accessors that access data using a provided proc
  module Mapping
    extend ActiveSupport::Concern

    attr_accessor :mapping

    module ClassMethods

      def map(name, block)
        instance.mapping[name] = block
      end
    end

    def initialize
      self.mapping = {}
      super
    end
  end
end
