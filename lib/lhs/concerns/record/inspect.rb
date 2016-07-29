require 'active_support'

class LHS::Record

  module Inspect
    extend ActiveSupport::Concern

    def inspect
      [
        "#{self.class}##{object_id}",
        pretty_raw
      ].join("\n")
    end

    private

    def pretty_raw
      return if _data._raw.blank?
      if _data._raw.is_a?(Array)
        _data._raw
      else
        _data._raw.to_a.map { |key, value| ":#{key} => #{value}" }
      end.join("\n")
    end
  end
end
