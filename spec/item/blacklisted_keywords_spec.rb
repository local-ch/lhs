# frozen_string_literal: true

require 'spec_helper'
require 'lhs'

describe LHS::Item do

  before do
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
      Record.where(color: :blue).each do |record|
        expect(record.respond_to_missing?(:new)).to eq false
        expect(record.respond_to_missing?(:proxy_association)).to eq false
        expect(record.respond_to_missing?(:name)).to eq true
      end
    end
  end
end
