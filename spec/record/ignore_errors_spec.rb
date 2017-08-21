require 'rails_helper'

describe LHS::Record do
  let(:handler) { spy('handler') }

  before(:each) do
    class Record < LHS::Record
      endpoint 'http://local.ch/v2/records'
      endpoint 'http://local.ch/v2/records/:id'
    end
  end

  context 'ignore errors' do
    it 'allows to ignore errors' do
      stub_request(:get, "http://local.ch/v2/records?color=blue").to_return(status: 404)
      record = Record
        .where(color: 'blue')
        .ignore(LHC::NotFound)
        .fetch
      expect(record).to eq nil
    end
  end

  context 'multiple ignored errors' do
    it 'ignores error if one of them is specified' do
      stub_request(:get, "http://local.ch/v2/records?color=blue").to_return(status: 401)
      record = Record
        .ignore(LHC::Unauthorized)
        .where(color: 'blue')
        .ignore(LHC::NotFound)
        .fetch
      expect(record).to eq nil
    end

    it 'ignores error if one of them is specified' do
      stub_request(:get, "http://local.ch/v2/records?color=blue").to_return(status: 404)
      record = Record
        .ignore(LHC::Unauthorized)
        .where(color: 'blue')
        .ignore(LHC::NotFound)
        .fetch
      expect(record).to eq nil
    end
  end

  it 'also can ignore all LHC errors' do
    stub_request(:get, "http://local.ch/v2/records?color=blue").to_return(status: 401)
    record = Record
      .ignore(LHC::Error)
      .where(color: 'blue')
      .fetch
    expect(record).to eq nil
  end

  it 'can ignore multiple error with one ignore call' do
    stub_request(:get, "http://local.ch/v2/records?color=blue").to_return(status: 401)
    record = Record
      .ignore(LHC::Unauthorized, LHC::NotFound)
      .where(color: 'blue')
      .fetch
    expect(record).to eq nil
  end

  it 'can ignore multiple error with one ignore call, on chain start' do
    stub_request(:get, "http://local.ch/v2/records?color=blue").to_return(status: 401)
    record = Record
      .ignore(LHC::Unauthorized, LHC::NotFound)
      .where(color: 'blue')
      .fetch
    expect(record).to eq nil
  end

  it 'can ignore multiple error with one ignore call, also within the chain' do
    stub_request(:get, "http://local.ch/v2/records?color=blue").to_return(status: 401)
    record = Record
      .where(color: 'blue')
      .ignore(LHC::Unauthorized, LHC::NotFound)
      .fetch
    expect(record).to eq nil
  end
end
