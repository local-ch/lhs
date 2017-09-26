module LHS::Problems
  class Warnings < Base

    def initialize(raw, record = nil)
      @raw = raw
      @record = record
      @messages = warnings_from_raw
    end

    private

    def warnings_from_raw
      messages = {}
      return messages if !raw.is_a?(Hash) || raw[:field_warnings].blank?
      raw[:field_warnings].each do |field_warning|
        add_error(messages, field_warning[:path].join('.').to_sym, field_warning[:code])
      end
      messages.with_indifferent_access
    end
  end
end
