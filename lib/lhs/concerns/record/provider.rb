# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

class LHS::Record

  # A provider can define options used for that specific provider
  module Provider
    extend ActiveSupport::Concern

    included do
      class_attribute :provider_options unless defined? provider_options
      self.provider_options = nil
    end

    module ClassMethods
      def provider(options = nil)
        self.provider_options = options
      end
    end
  end
end
