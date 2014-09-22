require 'rails_helper'

describe LHS::Data do

  let(:data) do
    LHS::Data.new({
      href: 'http://www.local.ch/v2/stuff'
    })
  end

  let(:loaded_data) do
    LHS::Data.new({
      href: 'http://www.local.ch/v2/stuff',
      id: '123123123'
    })
  end

  context 'merging' do

    it 'merges data' do
      data.merge!(loaded_data)
      expect(data.id).to eq loaded_data.id
    end
  end
end
