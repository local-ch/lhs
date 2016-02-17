require 'rails_helper'

describe LHS::Collection do
  let(:data) {
    ['ROLE_USER', 'ROLE_LOCALCH_ACCOUNT']
  }

  let(:collection){
    LHS::Data.new(LHS::Data.new(data))
  }

  context '#respond_to?' do
    # In this case raw collection is an Array implementing first
    it 'forwards calls to raw collection' do
      expect(collection.respond_to?(:first)).to be(true)
    end
  end
end
