# frozen_string_literal: true

require 'rails_helper'

describe LHS::Collection do
  let(:items) { [{ name: 'Steve' }] }
  let(:extra) { 'extra' }
  let(:collection) { Record.where }

  context 'to_ary' do
    before do
      class Record < LHS::Record
        endpoint 'http://datastore/records`'
      end
      stub_request(:get, %r{http://datastore/records})
        .to_return(body: response_data.to_json)
    end

    let(:response_data) do
      {
        items: items,
        extra: extra,
        total: 1
      }
    end

    let(:subject) { collection.to_ary }

    it 'returns an array' do
      expect(subject).to be_present
      expect(subject).to be_kind_of Array
      expect(subject[0]).to be_kind_of Record
      expect(subject[0].name).to eq 'Steve'
    end

    it 'responds to to_ary' do
      expect(subject.respond_to?(:to_ary)).to eq true
    end
  end
end
