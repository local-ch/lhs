require 'rails_helper'

describe LHS::Record do
  before(:each) do
    class Record < LHS::Record
      endpoint 'http://datastore/records/:id'
    end
    stub_request(:get, "http://datastore/records/1")
      .to_return(body: {
        name: 'Steve',
        kind: {
          animal: {
            type: 'Monkey'
          }
        }
      }.to_json)
  end

  let(:record) { Record.find(1) }

  context 'inspect' do
    it 'prints the record on the terminal: each attrbitute on a new line' do
      expect(record.inspect).to eq "Record##{record.object_id}\n:name => \"Steve\"\n:kind => {:animal=>{:type=>\"Monkey\"}}"
    end
  end
end
