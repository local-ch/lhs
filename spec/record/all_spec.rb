require 'rails_helper'

describe LHS::Record do
  let(:datastore) do
    'http://datastore/v2'
  end

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint ':datastore/feedbacks'
    end
  end

  context 'all' do
    it 'is querying endpoint without pagination when using all' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100").to_return(status: 200, body: { items: 300.times.map { { foo: 'bar' } }, total: 300 }.to_json)
      records = Record.all
      expect(records).to be_kind_of Record
      expect(records.size).to eq(300)
    end
  end
end
