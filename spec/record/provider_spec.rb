# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'provider' do

    before do
      module Provider
        class BaseRecord < LHS::Record
          provider params: { api_key: 123 }
        end

        class Record < Provider::BaseRecord
          endpoint 'http://provider/records'
        end
      end

      class AnotherRecord < LHS::Record
        endpoint 'http://other_provider/records'
      end

      stub_request(:get, "http://provider/records?id=1&api_key=123")
        .to_return(body: { name: 'Steve' }.to_json)

      stub_request(:get, "http://other_provider/records?id=1")
        .to_return(body: { name: 'Not Steve' }.to_json)
    end

    it 'applies provider options when making requests to that provider' do
      record = Provider::Record.find(1)
      expect(record.name).to eq 'Steve'
    end

    it 'does not apply provider options when making requests to other records' do
      Provider::Record.find(1)
      record = AnotherRecord.find(1)
      expect(record.name).to eq 'Not Steve'
    end
  end
end
