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

  context 'multiple errors' do
  end
end
