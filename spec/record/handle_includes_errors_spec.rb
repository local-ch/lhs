# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  let(:handler) { spy('handler') }

  before do
    class Record < LHS::Record
      endpoint 'http://local.ch/v2/records/{id}'
    end
    class NestedRecord < LHS::Record
      endpoint 'http://local.ch/v2/other_records/{id}'
    end
    stub_request(:get, "http://local.ch/v2/records/1")
      .to_return(body: {
        href: 'http://local.ch/v2/records/1',
        other: {
          href: 'http://local.ch/v2/other_records/2'
        }
      }.to_json)
    stub_request(:get, "http://local.ch/v2/other_records/2")
      .to_return(status: 404)
  end

  it 'allows to pass error_handling for includes to LHC' do
    handler = ->(_) { return { deleted: true } }
    record = Record.includes(:other).references(other: { error_handler: { LHC::NotFound => handler } }).find(id: 1)

    expect(record.other.deleted).to be(true)
  end
end
