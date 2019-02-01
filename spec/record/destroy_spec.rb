# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'destroy' do
    before do
      class Record < LHS::Record
        endpoint 'http://datastore/history'
        endpoint 'http://datastore/history/{id}'
      end
    end

    let(:entry) { { id: '33221', what: 'Cafe', where: 'Zurich' } }

    it 'allows to destroy by parameters directly' do
      stub_request(:delete, "http://datastore/history?what=Cafe&where=Zurich")
        .to_return(body: [entry].to_json)
      deleted_entries = Record.destroy(what: 'Cafe', where: 'Zurich')
      expect(deleted_entries.first.to_h).to eq entry
    end

    it 'allows to destroy by id' do
      stub_request(:delete, "http://datastore/history/1")
        .to_return(body: entry.to_json)
      deleted_entry = Record.destroy(1)
      expect(deleted_entry.to_h).to eq entry
    end

    it 'chains' do
      stub_request(:delete, "http://datastore/history/1")
        .with(headers: { 'Authorization' => 'Bearer 123' })
        .to_return(body: entry.to_json)
      deleted_entry = Record.options(headers: { 'Authorization' => 'Bearer 123' }).destroy(1)
      expect(deleted_entry.to_h).to eq entry
    end

    it 'chains without parameter' do
      stub_request(:delete, "http://datastore/history/1")
        .with(headers: { 'Authorization' => 'Bearer 123' })
        .to_return(body: entry.to_json)

      entry_record = Record.new(entry)
      deleted_entry = entry_record.destroy

      expect(deleted_entry.to_h).to eq entry
    end
  end
end
