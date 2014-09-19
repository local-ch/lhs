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

  let(:link) do
    item.campaign
  end

  context 'link' do

    it 'is providing nested data if present already' do
      pending
    end

    it 'is loading data remotely when not present yet' do
      pending
    end

    it 'can be reloaded' do
      pending
    end
  end
end
