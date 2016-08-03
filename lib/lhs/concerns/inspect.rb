require 'active_support'

module Inspect
  extend ActiveSupport::Concern

  def inspect
    [
      "#{to_s.match('LHS::Data') ? 'Data of ' : nil}#{self.class}##{object_id}",
      pretty_raw
    ].compact.join("\n")
  end

  private

  def pretty_raw
    return if _raw.blank?
    if _raw.is_a?(Array)
      _raw
    else
      _raw.to_a.map do |key, value|
        ":#{key} => " +
          if value.is_a? String
            "\"#{value}\""
          else
            value.to_s
          end
      end
    end.join("\n")
  end
end
