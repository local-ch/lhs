require 'rails_helper'

describe LHS::Collection do
  let(:collection) do
    LHS::Collection.new(LHS::Data.new([]))
  end

  context 'array misses href' do
    it 'works with empty array' do
      expect(
        collection.href
      ).to eq nil
    end
  end
end
