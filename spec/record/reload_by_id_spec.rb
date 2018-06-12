require 'rails_helper'

describe LHS::Record do
  before do
    class Record < LHS::Record
      endpoint 'http://datastore/records'
      endpoint 'http://datastore/records/{id}'
    end

    class AnotherRecord < LHS::Record
      endpoint 'http://datastore/otherrecords'
      endpoint 'http://datastore/otherrecords/{id}'

      def id
        another_id
      end
    end
  end

  context 'reload!' do
    it 'reloads the record by id' do
      stub_request(:post, "http://datastore/records")
        .to_return(body: { id: 1, name: 'Steve' }.to_json)
      record = Record.create!(name: 'Steve')
      stub_request(:get, "http://datastore/records/1")
        .to_return(body: { id: 1, name: 'Steve', async: 'data' }.to_json)
      record.reload!
      expect(record.async).to eq 'data'
    end

    it 'reloads the record by id if a record method defines the actual id' do
      stub_request(:post, "http://datastore/otherrecords")
        .to_return(body: { another_id: 2, name: 'Can' }.to_json)
      record = AnotherRecord.create!(name: 'Can')
      stub_request(:get, "http://datastore/otherrecords/2")
        .to_return(body: { id: 2, name: 'Can', async: 'data' }.to_json)
      record.reload!
      expect(record.async).to eq 'data'
    end
  end
end
