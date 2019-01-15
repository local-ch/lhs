# frozen_string_literal: true

require 'rails_helper'

describe LHS::Collection do
  let(:items) { [{ name: 'Steve' }] }
  let(:extra) { 'extra' }
  let(:collection) { Record.where }

  context 'accessors' do
    let(:response_data) do
      {
        items: items,
        extra: extra,
        total: 1
      }
    end

    before do
      class Record < LHS::Record
        endpoint 'http://datastore/records`'
      end
      stub_request(:get, %r{http://datastore/records})
        .to_return(body: response_data.to_json)
    end

    it 'allows access to extra data passed with collection' do
      expect(collection.extra).to eq(extra)
    end
  end
end
