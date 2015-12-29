require 'rails_helper'

describe LHS::Collection do

  let(:data) {
    [1, 2, 3]
  }

  let(:collection){
    described_class.new(LHS::Data.new(data))
  }

  context 'enumerable' do

    it 'works with map' do
      expect(
        collection.map{|x| x + 1}
      ).to eq [2, 3, 4]
    end

    it 'works with select' do
      expect(
        collection.select{|x| x == 2}
      ).to eq [2]
    end
  end
end
