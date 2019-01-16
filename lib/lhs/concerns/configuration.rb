# frozen_string_literal: true

require 'active_support'

module LHS
  module Configuration
    extend ActiveSupport::Concern

    module ClassMethods
      def config
        LHS::Config.instance
      end

      def configure
        LHS::Config.instance.reset
        yield config
      end
    end
  end
end
