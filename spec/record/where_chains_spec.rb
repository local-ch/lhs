require 'rails_helper'

describe LHS::Record do
  let(:datastore) do
    'http://datastore/v2'
  end

  let(:response) do
    { body: [{ name: 'Steve' }] }
  end

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint ':datastore/records/'

      def uppercase_name
        name.upcase
      end
    end
  end

  context 'where chains' do
    before(:each) do
      stub_request(:get, "http://datastore/v2/records/?available=true&color=blue&range=%3E26")
        .to_return(response)
    end

    let(:records) { Record.where(color: 'blue').where(range: '>26').where(available: true) }

    it 'allows chaining where statements' do
      expect(records.class).to eq Record
      expect(records._raw).to eq [{ name: 'Steve' }]
      expect(records.first.uppercase_name).to eq 'STEVE'
    end

    it 'resolves triggered by method missing' do
      expect(records._raw).to eq [{ name: 'Steve' }]
      expect(
        Record.where(color: 'blue').where(range: '>26', available: true).first.name
      ).to eq 'Steve'
    end
  end

  context 'multiple parameters' do
    before(:each) do
      stub_request(:get, "http://datastore/v2/records/?parameter=last").to_return(response)
    end

    it 'takes the last value for chains with same name parameters' do
      records = Record.where(parameter: 'first').where(parameter: 'last')
      records.first
    end
  end
end
