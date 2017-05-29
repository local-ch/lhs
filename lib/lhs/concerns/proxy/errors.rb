require 'active_support'

class LHS::Proxy

  module Errors
    extend ActiveSupport::Concern

    included do
      attr_accessor :errors
    end

    def initialize(data)
      super(data)
      self.errors = LHS::Errors::Base.new
    end
  end
end
