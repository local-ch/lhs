# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'update' do

    before do
      class Record < LHS::Record
        endpoint 'http://datastore/records/{id}'
      end
    end

    it 'allows to directly update a record without fetching it first' do
      stub_request(:post, "http://datastore/records/123")
        .with(body: {name: 'Steve'}.to_json)
        .to_return(status: 200, body: {}.to_json)

      Record.update(
        id: '123',
        name: 'Steve'
      )
    end

    it 'does not fail during an error with update' do
      stub_request(:post, "http://datastore/records/123")
        .with(body: {name: 'Steve'}.to_json)
        .to_return(status: 404, body: {}.to_json)

      record = Record.update(
        id: '123',
        name: 'Steve'
      )

      expect(record.errors.status_code).to eq 404
    end

    it 'allows to directly update a record without fetching it first' do
      stub_request(:post, "http://datastore/records/123")
        .with(body: {name: 'Steve'}.to_json)
        .to_return(status: 200)

      Record.update!(
        id: '123',
        name: 'Steve'
      )
    end

    it 'allows to directly update a record without fetching it first' do
      stub_request(:post, "http://datastore/records/123")
        .with(body: {name: 'Steve'}.to_json)
        .to_return(status: 404)

      expect(->{
        Record.update!(
          id: '123',
          name: 'Steve'
        )
      }).to raise_error(LHC::NotFound)
    end
  end
end
