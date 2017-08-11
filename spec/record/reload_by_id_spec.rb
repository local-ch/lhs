require 'rails_helper'

describe LHS::Record do
  before(:each) do
    class Record < LHS::Record
      endpoint 'http://datastore/records'
      endpoint 'http://datastore/records/:id'
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
  end
end
