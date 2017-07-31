require 'active_support'

class LHS::Item < LHS::Proxy

  module Becomes
    extend ActiveSupport::Concern

    def becomes(klass)
      klass.new(_raw)
    end
  end
end
