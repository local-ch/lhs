require 'active_support'

class LHS::Proxy

  module Errors
    extend ActiveSupport::Concern

    included do
      attr_writer :errors
    end

    def initialize(data)
      super(data)
      self.errors = LHS::Errors::Base.new
    end

    def errors
      @errors ||= LHS::Errors::Base.new
    end
  end
end
