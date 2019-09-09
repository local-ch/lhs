# frozen_string_literal: true

require 'rails_helper'
require 'lhs/rspec'

describe LHS do

  before do
    class Record < LHS::Record
      endpoint 'https://records'
    end

    LHS.stub.all(
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
end
