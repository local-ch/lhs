require 'active_support'

class LHS::Data

  module Becomes
    extend ActiveSupport::Concern

    def becomes(klass)
      klass.new(_raw)
    end
  end
end
