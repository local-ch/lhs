# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context '#accepts_nested_attributes_for' do
    it 'raises ArgumentError if association has not been defined' do
      expect(lambda do
        Class.new(LHS::Record) do
          # use `SecureRandom` to avoid any regressions of `self._relations` with other specs
          accepts_nested_attributes_for SecureRandom.urlsafe_base64.to_sym
        end
      end).to raise_error ArgumentError
    end
  end
end
