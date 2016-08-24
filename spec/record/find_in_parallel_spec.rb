require 'rails_helper'

describe LHS::Record do
  before(:each) do
    class Record < LHS::Record
      endpoint 'http://datastore/records/:id'
    end
  end

  context 'find in parallel' do
    before(:each) do
      stub_request(:get, "http://datastore/records/1").to_return(status: 200, body: {id: 1}.to_json)
      stub_request(:get, "http://datastore/records/2").to_return(status: 200, body: {id: 2}.to_json)
    end

    it 'finds records in parallel' do
      stub_request(:get, "http://datastore/records/3").to_return(status: 200, body: {id: 3}.to_json)
      allow(Record).to receive(:request).and_call_original
      data = Record.find([1, 2, 3])
      expect(Record).to have_received(:request).once
      expect(data[0].id).to eq 1
      expect(data[1].id).to eq 2
      expect(data[2].id).to eq 3
    end

    it 'raises an exeption if one of the parallel request fails' do
      stub_request(:get, "http://datastore/records/3").to_return(status: 401)
      expect(-> { Record.find([1, 2, 3]) }).to raise_error(LHC::Unauthorized)
    end

    it 'applies error handlers from the chain and returns whatever the error handler returns' do
      stub_request(:get, "http://datastore/records/3").to_return(status: 401)
      data = Record
        .handle(LHC::Unauthorized, ->(response) { Record.new })
        .find([1, 2, 3])
      binding.pry
    end
  end
end
