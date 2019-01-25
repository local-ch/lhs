# frozen_string_literal: true

require 'rails_helper'

describe LHS::Collection do
  let(:items) { [{ name: 'Steve' }] }
  let(:extra) { 'extra' }
  let(:collection) { Record.where }

  context 'to_a' do
    let(:response_data) do
      {
        items: items,
        extra: extra,
        total: 1
      }
    end

    let(:subject) { collection.to_a }

    before do
      class Record < LHS::Record
        endpoint 'http://datastore/records`'
      end
      stub_request(:get, %r{http://datastore/records})
        .to_return(body: response_data.to_json)
    end

    it 'returns an array and not LHS::Data' do
      expect(subject).to be_kind_of Array
      expect(subject).not_to be_kind_of LHS::Data
    end
  end
end
