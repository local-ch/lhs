require 'rails_helper'

describe LHS::Data do
  context 'equality' do
    before(:each) do
      class Record < LHS::Record
        endpoint 'http://local.ch/records'
      end
    end

    let(:raw) do
      { name: 'Steve' }
    end

    it 'is equal when two data objects share the same raw data' do
      expect(
        LHS::Data.new(raw, nil, Record)
      ).to eq LHS::Data.new(raw, nil, Record)
    end
  end
end
