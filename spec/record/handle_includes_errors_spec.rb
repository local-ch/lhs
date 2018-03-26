require 'rails_helper'

describe LHS::Record do
  let(:handler) { spy('handler') }

  before(:each) do
    class Record < LHS::Record
      endpoint 'http://local.ch/v2/records'
    end
    class NestedRecord < LHS::Record
      endpoint 'http://local.ch/v2/other_records/:id'
    end
    stub_request(:get, "http://local.ch/v2/records")
      .to_return(body: {
        items: [{
          other: {
            href: 'http://local.ch/v2/other_records/2'
          }
        }]
      }.to_json)
    stub_request(:get, "http://local.ch/v2/other_records/2")
      .to_return(status: 404)
  end

  it 'allows to chain error handling' do
    handler = ->(){ binding.pry }
    records = Record.includes(:other).references(other: { error_handler: { LHC::NotFound => handler } }).where.fetch
    binding.pry
  end
end
