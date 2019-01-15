# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  let(:record) do
    LHS::Record.new(LHS::Data.new(['cat', 'dog']))
  end

  context 'select' do
    it 'works with select' do
      expect(
        record.select { |x| x }.join
      ).to eq 'catdog'
    end
  end
end
