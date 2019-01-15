# frozen_string_literal: true

require 'rails_helper'

describe LHS::Data do
  before do
    class Record < LHS::Record
      endpoint 'http://local.ch/records'
    end
  end

  let(:item) do
    {
      customer: {
        addresses: [
          {
            first_line: 'Bachstr. 6'
          }
        ]
      }
    }
  end

  let(:data) do
    LHS::Data.new(
      {
        href: 'http://local.ch/records',
        items: [item]
      }, nil, Record
    )
  end

  it 'provides the information which type of proxy data ist' do
    expect(data.collection?).to eq true
    expect(data.first.item?).to eq true
    expect(data.first.customer.item?).to eq true
    expect(data.first.customer.addresses.collection?).to eq true
    expect(data.first.customer.addresses.first.item?).to eq true
  end
end
