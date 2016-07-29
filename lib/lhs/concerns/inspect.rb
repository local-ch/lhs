require 'active_support'

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
    return if _raw.blank?
    if _raw.is_a?(Array)
      _raw
    else
      _raw.to_a.map { |key, value| ":#{key} => #{value}" }
    end.join("\n")
  end
end
