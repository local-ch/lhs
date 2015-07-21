require 'rails_helper'

describe LHS::Data do

  before(:each) do
    class SomeService < LHS::Service
      map :test_mapping?, ->(item){ true }
    end
  end

  context '#respond_to?' do

    it 'it is true for mappings that are defined' do
      data = described_class.new({'campaign' => {'id' => 123}}, nil, SomeService)

      expect(data.respond_to?(:test_mapping?)).to be(true)
    end

    # proxy for this example is LHC::Collection which implements total
    it 'it is true for calls forwarded to proxy' do
      data = described_class.new({'items' => [{'campaign' => {'id' => 123}}]}, nil, SomeService)

      expect(data.respond_to?(:total)).to be(true)
    end
  end
end
