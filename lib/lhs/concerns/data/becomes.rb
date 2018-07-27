require 'active_support'

class LHS::Data

  module Becomes
    extend ActiveSupport::Concern

    def becomes(klass)
      return self if self.class == klass
      klass.new(LHS::Data.new(_raw, _parent, klass))
    end
  end
end
