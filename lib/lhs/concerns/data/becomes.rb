require 'active_support'

class LHS::Data

  module Becomes
    extend ActiveSupport::Concern

    def becomes(klass, errors = nil)
      return self if self.class == klass && !is_a?(LHS::Data)
      data = LHS::Data.new(_raw, _parent, klass)
      data.errors = errors if errors
      klass.new(data)
    end
  end
end
