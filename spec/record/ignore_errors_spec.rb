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
    before(:each) do
      stub_request(:get, "http://local.ch/v2/records?color=blue").to_return(status: 404)
    end

    it 'allows to ignore errors' do
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
end
