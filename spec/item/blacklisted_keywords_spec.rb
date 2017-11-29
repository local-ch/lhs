require 'spec_helper'
require 'lhs'

describe LHS::Item do

  before(:each) do
    class Record < LHS::Record
      endpoint 'http://datastore/v2/records'
    end
  end

  context 'requires active support when dealing with Item' do

    it "does not raise an error" do
      stub_request(:get, "http://datastore/v2/records?color=blue")
        .to_return(
          body: {
            items: [{ name: 'Steve' }]
          }.to_json
        )
      Record.where(color: :blue).map do |record|
        record.name
      end
    end
  end
end
