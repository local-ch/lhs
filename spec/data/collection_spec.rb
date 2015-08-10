require 'rails_helper'

describe LHS::Data do

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    LHS::Data.new(json)
  end

  context 'collections' do

    it 'forwards calls to the collection' do
      expect(data.count).to be_kind_of Fixnum
      expect(data[0]).to be_kind_of LHS::Data
      expect(data.sample).to be_kind_of LHS::Data
    end

    it 'provides a total method to get the number of total records' do
      expect(data.total).to be_kind_of Fixnum
    end
  end

  context 'collections from arrays' do

    let(:data) do
      LHS::Data.new([1,2,3,4])
    end

    it 'uses collection as proxy for arrays' do
      expect(data._proxy).to be_kind_of LHS::Collection
    end
  end
end
