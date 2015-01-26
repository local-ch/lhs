require 'active_support'

class LHS::Data < LHS::Proxy

  module Json
    extend ActiveSupport::Concern

    def as_json(options = {})
      _data_._raw_.as_json
    end
  end
end
