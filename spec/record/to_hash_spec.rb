require 'rails_helper'

describe LHS::Record do
  before do
    class Record < LHS::Record
      endpoint 'http://datastore/records'
    end
  end

  let(:item) { { name: 'Thomas' } }
  let(:body) { [item] }

  it 'converts itself to hash' do
    stub_request(:get, "http://datastore/records")
      .to_return(body: body.to_json)
    record = Record.where.first
    expect(record.to_h).to eq item
    expect(record.to_hash).to eq item
  end
end
