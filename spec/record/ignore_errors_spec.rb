# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  let(:handler) { spy('handler') }
  let(:record_json) { { color: 'blue' }.to_json }

  before do
    class Record < LHS::Record
      endpoint 'http://local.ch/v2/records'
      endpoint 'http://local.ch/v2/records/{id}'
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
    it 'ignores error if first of them is specified' do
      stub_request(:get, "http://local.ch/v2/records?color=blue").to_return(status: 401)
      record = Record
        .ignore(LHC::Unauthorized)
        .where(color: 'blue')
        .ignore(LHC::NotFound)
        .fetch
      expect(record).to eq nil
    end

    it 'ignores error if last of them is specified' do
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

  it 'returns record when ignoring errors on where' do
    stub_request(:get, 'http://local.ch/v2/records?color=blue').to_return(status: 200, body: record_json)
    record = Record
      .ignore(LHC::Error)
      .where(color: 'blue')
    expect(record).not_to eq nil
  end

  context 'response body' do

    let(:body) { { error_message: 'you are not worthy' }.to_json }

    it 'returns nil also when ignoring errors on find' do
      stub_request(:get, "http://local.ch/v2/records/1").to_return(status: 500, body: body)
      record = Record
        .ignore(LHC::Error)
        .find(1)
      expect(record).to eq nil
    end

    it 'returns nil also when ignoring errors on find with parameters' do
      stub_request(:get, "http://local.ch/v2/records/1").to_return(status: 500, body: body)
      record = Record
        .ignore(LHC::Error)
        .find(id: 1)
      expect(record).to eq nil
    end

    it 'returns nil also when ignoring errors on fetch' do
      stub_request(:get, "http://local.ch/v2/records?color=blue").to_return(status: 500, body: body)
      record = Record
        .ignore(LHC::Error)
        .where(color: 'blue')
        .fetch
      expect(record).to eq nil
    end

    it 'returns nil also when ignoring errors on find_by' do
      stub_request(:get, "http://local.ch/v2/records?color=blue&limit=1").to_return(status: 500, body: body)
      record = Record
        .ignore(LHC::Error)
        .find_by(color: 'blue')
      expect(record).to eq nil
    end

    it 'returns record when ignoring errors on find' do
      stub_request(:get, "http://local.ch/v2/records/1").to_return(status: 200, body: record_json)
      record = Record
        .ignore(LHC::Error)
        .find(1)
      expect(record).not_to eq nil
    end
  end
end
