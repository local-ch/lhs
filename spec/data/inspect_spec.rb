require 'rails_helper'

describe LHS::Data do
  context 'inspect' do
    before(:each) do
      class Record < LHS::Record
        endpoint 'http://local.ch/records'
      end
    end

    let(:raw) do
      { pets: [
        {
          name: 'Steve',
          kind: {
            animal: {
              type: 'Monkey'
            }
          }
        }
      ] }
    end

    let(:data) do
      LHS::Data.new(raw, nil, Record).pets.first
    end

    it 'prints inspected data on multiple lines' do
      expect(data.inspect).to eq "Data of Record##{data.object_id}\n:name => \"Steve\"\n:kind => {:animal=>{:type=>\"Monkey\"}}"
    end
  end
end
