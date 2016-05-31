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

    let(:data) do
      LHS::Data.new(raw, nil, Record)
    end

    it 'provides inspect method that is focused on the raw data' do
      expect(data.inspect).to eq raw
      expect(data.inspect_without_focus).to include 'LHS::Data'
    end
  end
end
