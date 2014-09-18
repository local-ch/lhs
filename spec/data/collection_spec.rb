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
    end

  end
end
