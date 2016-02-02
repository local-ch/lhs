require 'active_support'

class LHS::Data

  module Json
    extend ActiveSupport::Concern

    def as_json(_options = {})
      _data._raw.as_json
    end
  end
end
