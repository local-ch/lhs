require 'rails_helper'

describe LHS::Record do
  before(:each) do
    class Record < LHS::Record
      endpoint 'http://datastore/records'
      endpoint 'http://datastore/records/:id'
    end
  end

  let(:json) do
    { id: 1, name: 'Steve' }.to_json
  end

  context 'reload!' do
    it 'returns an instance of the record, not an LHS::Item' do
      stub_request(:post, "http://datastore/records").to_return(body: json)
      stub_request(:get, "http://datastore/records/1").to_return(body: json)
      record = Record.create!(name: 'Steve')
      expect(record).to be_kind_of Record
      expect(record.reload!).to be_kind_of Record
    end
  end
end
