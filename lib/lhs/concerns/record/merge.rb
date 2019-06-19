# frozen_string_literal: true

require 'active_support'

class LHS::Record

  module Merge
    extend ActiveSupport::Concern

    def merge(other)
      _record.new(_data.to_h.merge(other.to_h))
    end

    def merge!(other)
      _data._raw.merge!(other.to_h)
    end

    def deep_merge(other)
      _record.new(_data.to_h.deep_merge(other.to_h))
    end

    def deep_merge!(other)
      _data._raw.deep_merge!(other.to_h)
    end
  end
end
