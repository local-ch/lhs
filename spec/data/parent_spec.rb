require 'rails_helper'

describe LHS::Data do
  before(:each) do
    class Record < LHS::Record
      endpoint 'http://local.ch/records'
    end
  end

  let(:item) do
    {
      customer: {
        address: {
          first_line: 'Bachstr. 6'
        }
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

  it 'possible to navigate the parent' do
    expect(
      data.first.customer.address.parent
    ).to eq data.first.customer
    expect(
      data.first.customer.address.parent.parent
    ).to eq data.first
  end
end
