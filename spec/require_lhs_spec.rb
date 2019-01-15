# frozen_string_literal: true

describe LHS do
  context 'when requiring lhs' do
    it 'does not raise an exception' do
      expect { require 'lhs' }.not_to raise_error
    end
  end
end
