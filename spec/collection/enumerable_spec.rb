# frozen_string_literal: true

require 'rails_helper'

describe LHS::Collection do
  let(:data) do
    [1, 2, 3]
  end

  let(:collection) do
    LHS::Collection.new(LHS::Data.new(data))
  end

  context 'enumerable' do
    it 'works with map' do
      expect(
        collection.map { |x| x + 1 }
      ).to eq [2, 3, 4]
    end

    it 'works with select' do
      expect(
        collection.select { |x| x == 2 }
      ).to eq [2]
    end
  end
end
