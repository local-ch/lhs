require 'rails_helper'

describe LHS::Record do
  context 'inspect' do
    before(:each) do
      class Record < LHS::Record
        endpoint 'http://local.ch/records/:id'
      end
    end

    let(:raw) do
      { name: 'Steve' }
    end

    let(:record) do
      Record.find(1)
    end

    it 'provides inspect method that is focused on the raw data' do
      stub_request(:get, "http://local.ch/records/1")
        .to_return(body: raw.to_json)
      expect(record.inspect).to eq "<Record #{raw.inspect}>"
    end
  end
end
