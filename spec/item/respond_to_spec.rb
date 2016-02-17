require 'rails_helper'

describe LHS::Item do
  let(:item){
    LHS::Item.new(id: 1234)
  }

  context '#respond_to?' do
    it 'is true for setters' do
      expect(item.respond_to?(:id=)).to be(true)
    end

    it 'is true for getters' do
      expect(item.respond_to?(:id)).to be(true)
    end

    it 'is true for brackets' do
      expect(item.respond_to?(:[])).to be(true)
    end

    it 'is false for new' do
      expect(item.respond_to?(:new)).to be(false)
    end

    it 'is false for proxy_association' do
      expect(item.respond_to?(:proxy_association)).to be(false)
    end
  end
end
