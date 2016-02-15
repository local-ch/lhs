require 'active_support'

class LHS::Record

  module JSON
    extend ActiveSupport::Concern

    def as_json(options = nil)
      _raw
    end
  end
end
