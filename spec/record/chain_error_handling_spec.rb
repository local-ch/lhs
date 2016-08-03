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
    @error_resolved = false
    @rescued = false
    begin
      record = Record.where(color: 'blue').handle(LHC::Error, ->(_error) { @error_resolved = true })
    rescue => _e
      @rescued = true
    end
    record.first
    expect(@error_resolved).to eq true
    expect(@rescued).to eq false
    # rubocop:enable RSpec/InstanceVariable
  end

  it 'reraises in case chained error is not matched' do
    # rubocop:disable RSpec/InstanceVariable
    @error_resolved = false
    @rescued = false
    record = Record.where(color: 'blue').handle(LHC::Conflict, ->(_error) { @error_resolved = true })
    begin
      record.first
    rescue => _e
      @rescued = true
    end
    expect(@error_resolved).to eq false
    expect(@rescued).to eq true
    # rubocop:enable RSpec/InstanceVariable
  end

  it 'calls all the handlers' do
    # rubocop:disable RSpec/InstanceVariable
    @error_resolved = 0
    @rescued = false
    begin
      record = Record.where(color: 'blue')
        .handle(LHC::Error, ->(_error) { @error_resolved += 1 })
        .handle(LHC::Error, ->(_error) { @error_resolved += 2 })
    rescue => _e
      @rescued = true
    end
    record.first
    expect(@error_resolved).to eq 3
    expect(@rescued).to eq false
    # rubocop:enable RSpec/InstanceVariable
  end
end
