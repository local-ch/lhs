require 'rails_helper'

describe LHS::Item do
  context 'accessors' do
    before do
      class Record < LHS::Record
        endpoint 'http://datastore/records'
      end
    end

    it 'accesses camel case keys using underscore syntax' do
      stub_request(:get, "http://datastore/records?id=1")
        .to_return(body: { 'AttributeValue' => 42 }.to_json)

      record = Record.find(1)
      expect(record.attribute_value).not_to be nil
    end
  end
end
