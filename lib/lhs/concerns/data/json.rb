# frozen_string_literal: true

require 'active_support'

class LHS::Data

  module Json
    extend ActiveSupport::Concern

    def as_json(options = {})
      _data._raw.as_json(options)
    end
  end
end
