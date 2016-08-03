require 'rails_helper'

describe LHS::Record do
  before(:each) do
    class Record < LHS::Record
      endpoint 'http://local.ch/v2/records'
    end
    stub_request(:get, "http://local.ch/v2/records?color=blue")
      .to_return(status: 400)
  end

  it 'allows to chain error handling' do
    # rubocop:disable RSpec/InstanceVariable
    @errorResolved = false
    @rescued = false
    begin
      record = Record.where(color: 'blue').handle(LHC::Error, ->(error){ @errorResolved = true })
    rescue => e
      @rescued = true
    end
    record.first
    expect(@errorResolved).to eq true
    expect(@rescued).to eq false
    # rubocop:enable RSpec/InstanceVariable
  end

  it 'reraises in case chained error is not matched' do
    # rubocop:disable RSpec/InstanceVariable
    @errorResolved = false
    @rescued = false
    record = Record.where(color: 'blue').handle(LHC::Conflict, ->(error){ @errorResolved = true })
    begin
      record.first
    rescue => _e
      @rescued = true
    end
    expect(@errorResolved).to eq false
    expect(@rescued).to eq true
    # rubocop:enable RSpec/InstanceVariable
  end
end
