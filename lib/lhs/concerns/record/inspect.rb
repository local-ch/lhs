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
      return pretty_raw_array if raw.is_a?(Array)
      pretty_raw_hash
    end

    def pretty_raw_array
      [
        '[',
        _data._raw,
        ']'
      ].flatten.join("\n")
    end

    def pretty_raw_hash
      [
        '{',
        _data._raw.to_a.map { |key, value| ":#{key} => #{value}" },
        '}'
      ].flatten.join("\n")
    end
  end
end
