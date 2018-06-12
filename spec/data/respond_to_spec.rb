require 'rails_helper'

describe LHS::Data do
  before do
    class Record < LHS::Record
      map :test_mapping?, ->(_item) { true }
    end
  end

  context '#respond_to?' do
    it 'is true for mappings that are defined' do
      data = LHS::Data.new({ 'campaign' => { 'id' => 123 } }, nil, Record)

      expect(data.respond_to?(:test_mapping?)).to be(true)
    end

    # proxy for this example is LHC::Collection which implements total
    it 'is true for calls forwarded to proxy' do
      data = LHS::Data.new({ 'items' => [{ 'campaign' => { 'id' => 123 } }] }, nil, Record)

      expect(data.respond_to?(:total)).to be(true)
    end
  end
end
