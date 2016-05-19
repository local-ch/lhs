require 'rails_helper'

describe LHS::Record do
  let(:datastore) do
    'http://datastore/v2'
  end

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint ':datastore/records'
    end
  end

  let(:options) { { auth: { bearer: '123' } } }
  let(:params) { { name: 'Steve' } }

  context 'options' do
    it 'is possible to pass options to the chain' do
      expect(LHC).to receive(:request)
        .with(options.merge(params: params).merge(url: 'http://datastore/v2/records'))
        .and_call_original
      stub_request(:get, "http://datastore/v2/records?name=Steve")
        .to_return(body: { name: "Steve", is: 'awesome' }.to_json)
      Record.options(options).where(params).first
    end

    it 'applies last one wins also to the options' do
      stub_request(:get, "http://datastore/v2/records")
        .to_return(body: { name: "Steve", is: 'awesome' }.to_json)
      expect(LHC).to receive(:request)
        .with({ auth: 'bearer' }.merge(url: 'http://datastore/v2/records'))
        .and_call_original
      Record.options(auth: 'bearer').options(auth: 'bearer').where.first
    end

    it 'is also applicable to find' do
      stub_request(:get, 'http://datastore/v2/records?id=123').to_return(body: {}.to_json)
      expect(LHC).to receive(:request)
        .with({ auth: 'bearer' }.merge(params: { id: "123" }, url: 'http://datastore/v2/records'))
        .and_call_original
      Record.options(auth: 'bearer').find('123')
    end

    it 'is also applicable to find_by' do
      stub_request(:get, 'http://datastore/v2/records?id=123&limit=1').to_return(body: {}.to_json)
      Record.options(auth: 'bearer').find_by(id: '123')
    end

    it 'is also applicable to first' do
      stub_request(:get, 'http://datastore/v2/records').to_return(body: {}.to_json)
      Record.options(auth: 'bearer').first
    end
  end
end
