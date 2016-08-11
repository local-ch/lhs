require 'rails_helper'

describe LHS::Record do
  before(:each) do
    class Record < LHS::Record
      endpoint 'http://datastore/records/:id'
    end
    stub_request(:get, "http://datastore/records/1")
      .to_return(body: attrbitutes.to_json)
  end

  let(:record) { Record.find(1) }
  let(:attrbitutes) do
    {
      name: 'Steve',
      kind: {
        animal: {
          type: 'Monkey'
        }
      }
    }
  end

  let(:output) { "Record##{record.object_id}\n:name => \"Steve\"\n:kind => {:animal=>{:type=>\"Monkey\"}}" }

  context 'inspect' do
    it 'prints the record on the terminal: each attrbitute on a new line' do
      expect(record.inspect).to eq(output)
    end

    context 'with custom setters that do no touch raw data' do
      before do
        class Record
          attr_accessor :listing
        end
      end

      let(:record) { Record.new(attrbitutes.merge(listing: double('listing'))) }

      it 'does not print what is not in raw' do
        expect(record.inspect).to eq(output)
      end
    end
  end
end
