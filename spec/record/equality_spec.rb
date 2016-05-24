require 'rails_helper'

describe LHS::Record do

  context 'equality' do

    before(:each) do
      class Record < LHS::Record
        endpoint 'http://local.ch/records'
      end
    end

    let(:raw) do
      { name: 'Steve' }
    end

    def record
      LHS::Record.new LHS::Data.new(raw, nil, Record)
    end

    it 'is equal when two data objects share the same raw data' do
      expect(
        record
      ).to eq record
    end
  end
end
