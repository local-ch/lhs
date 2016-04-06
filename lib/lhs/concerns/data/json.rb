require 'active_support'

class LHS::Data

  module Json
    extend ActiveSupport::Concern

    def as_json(options = {})
      if _data._raw.is_a?(Array)
        _data._raw.as_json(options)
      elsif _data._raw[:items].present?
        _data._raw[:items].as_json(options)
      else
        _data._raw.as_json
      end
    end
  end
end
