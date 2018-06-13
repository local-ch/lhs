require 'rails_helper'

describe LHS::Record do
  before do
    class Record < LHS::Record
      endpoint 'http://local.ch/v2/records'
    end
  end

  it 'always returns a new chain and does not mutate the original' do
    blue_request = stub_request(:get, "http://local.ch/v2/records?color=blue").to_return(body: [].to_json)
    blue_records = Record.where(color: 'blue')
    blue_active_request = stub_request(:get, "http://local.ch/v2/records?color=blue&active=true").to_return(body: [].to_json)
    active_blue_records = blue_records.where(active: true)
    blue_records.first
    active_blue_records.first
    assert_requested(blue_request)
    assert_requested(blue_active_request)
  end
end
