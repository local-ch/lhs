require 'rails_helper'

describe LHS::Record do

  context 'options' do
    before do
      class Record < LHS::Record
        endpoint 'http://local.ch/records'
      end
    end

    let(:raw) do
      { options: { criticality: :high } }
    end

    def record
      LHS::Record.new LHS::Data.new(raw, nil, Record)
    end

    it 'is possible to fetch data from a key called options from an instance' do
      expect(record.options.criticality).to eq :high
    end
  end
end
