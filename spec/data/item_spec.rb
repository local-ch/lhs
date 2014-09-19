require 'rails_helper'

describe LHS::Data do

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    LHS::Data.new(json)
  end

  let(:item) do
    data[0]
  end

  context 'item' do

    it 'makes data accessible' do
      expect(item.href).to be_kind_of String
      expect(item.recommended).to be_kind_of TrueClass
      expect(item.average_rating).to be_kind_of Float
    end
  end
end
