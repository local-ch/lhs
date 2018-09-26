require 'active_support'

class LHS::Record

  module CustomSetters
    extend ActiveSupport::Concern

    private

    def apply_custom_setters!
      return if !_data.item? || !_data._raw.respond_to?(:keys)
      raw = _data._raw
      custom_setters = raw.keys.find_all { |key| public_methods.include?("#{key}=".to_sym) }
      custom_setters.each do |setter|
        value = raw.delete(setter)
        send("#{setter}=", value)
      end
    end
  end
end
