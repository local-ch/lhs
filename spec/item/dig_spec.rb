require 'rails_helper'

describe LHS::Item do
  before(:each) do
    class Record < LHS::Record
      endpoint '{+datastore}/records'
    end
  end

  let(:json) do
    {
      local_entry: {
        local_entry_id: 'ABC123'
      }
    }
  end

  let(:item) do
    LHS::Data.new(json, nil, Record)
  end

  it 'is possible to dig data' do
    expect(
      item.dig(:local_entry, :local_entry_id)
    ).to eq 'ABC123'
  end
end
