# frozen_string_literal: true

require 'active_support'

class LHS::Data

  module Becomes
    extend ActiveSupport::Concern

    def becomes(klass, options = {})
      return self if self.class == klass && !is_a?(LHS::Data)
      data = LHS::Data.new(_raw, _parent, klass)
      data.errors = options[:errors] if options[:errors]
      data.warnings = options[:warnings] if options[:warnings]
      klass.new(data)
    end
  end
end
