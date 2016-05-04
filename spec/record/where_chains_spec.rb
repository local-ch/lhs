require 'rails_helper'

describe LHS::Record do
  let(:datastore) do
    'http://datastore/v2'
  end

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint ':datastore/records/'

      def self.blue
        where(color: 'blue')
      end

      def uppercase_name
        name.upcase
      end
    end
  end

  context 'where chains' do
    it 'allows chaining where statements' do
      stub_request(:get, "http://datastore/v2/records/?available=true&color=blue&range=%3E26")
        .to_return(body: [{ name: 'Steve' }])
      records = Record.blue.where(range: '>26')
      records = records.where(available: true)
      expect(records.class).to eq Record
      expect(records._raw).to eq [{ name: 'Steve' }]
      expect(records.first.uppercase_name).to eq 'STEVE'
    end
  end
end
