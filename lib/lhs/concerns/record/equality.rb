require 'active_support'

class LHS::Record

  module Equality
    extend ActiveSupport::Concern

    def ==(other)
      _raw == other.try(:_raw)
    end
  end
end
