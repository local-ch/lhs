# frozen_string_literal: true

require 'rails_helper'
require 'lhs/rspec'

describe LHS do

  before do
    class Record < LHS::Record
      endpoint 'https://records'
    end

    Record.stub_all(
      'https://records',
      200.times.map { |index| { name: "Item #{index}" } },
      headers: {
        'Authorization' => 'Bearer 123'
      }
    )
  end

  it 'stubs all requests' do
    records = Record.options(headers: { 'Authorization' => 'Bearer 123' }).all.fetch
    expect(records.count).to eq 200
    expect(records.length).to eq 200
    expect(records.first.name).to eq 'Item 0'
  end

  context 'without conditions' do

    before do
      class Record < LHS::Record
        endpoint 'https://records'
      end

      Record.stub_all(
        'https://records',
        200.times.map { |index| { name: "Item #{index}" } }
      )
    end

    it 'stubs all requests without a webmock "with"' do
      records = Record.all.fetch
      expect(records.count).to eq 200
      expect(records.length).to eq 200
      expect(records.first.name).to eq 'Item 0'
    end
  end

  context 'with configured record' do

    before do
      class Record < LHS::Record
        configuration limit_key: :per_page, pagination_strategy: :page, pagination_key: :page

        endpoint 'https://records'
      end

      Record.stub_all(
        'https://records',
        200.times.map { |index| { name: "Item #{index}" } }
      )
    end

    it 'stubs all requests with record configurations for pagination' do
      records = Record.all.fetch
      expect(records.count).to eq 200
      expect(records.length).to eq 200
      expect(records.first.name).to eq 'Item 0'
    end
  end
end
