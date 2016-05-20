require 'rails_helper'

describe LHS::Record do
  let(:datastore) do
    'http://datastore/v2'
  end

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint ':datastore/records', validates: true
    end
  end

  let(:options) { { auth: { bearer: '123' }, validates: true } }
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
        .with(options.merge(url: 'http://datastore/v2/records'))
        .and_call_original
      Record.options(auth: 'basic').options(options).where.first
    end

    it 'is also applicable to find' do
      stub_request(:get, 'http://datastore/v2/records?id=123').to_return(body: {}.to_json)
      expect(LHC).to receive(:request)
        .with(options.merge(params: { id: "123" }, url: 'http://datastore/v2/records'))
        .and_call_original
      Record.options(options).find('123')
    end

    it 'is also applicable to find_by' do
      stub_request(:get, 'http://datastore/v2/records?id=123&limit=1').to_return(body: {}.to_json)
      expect(LHC).to receive(:request)
        .with(options.merge(params: { id: "123", limit: 1 }, url: 'http://datastore/v2/records'))
        .and_call_original
      Record.options(options).find_by(id: '123')
    end

    it 'is also applicable to first' do
      stub_request(:get, 'http://datastore/v2/records').to_return(body: {}.to_json)
      expect(LHC).to receive(:request)
        .with(options.merge(url: 'http://datastore/v2/records'))
        .and_call_original
      Record.options(options).first
    end

    it 'is also applicable to create' do
      stub_request(:post, 'http://datastore/v2/records').to_return(body: {}.to_json)
      expect(LHC).to receive(:request)
        .with(options.merge(method: :post, url: "http://datastore/v2/records", body: "{\"name\":\"Steve\"}", headers: { 'Content-Type' => 'application/json' }))
        .and_call_original
      Record.options(options).create(name: 'Steve')
    end

    context 'actions on single records' do
      let!(:record) do
        stub_request(:get, "http://datastore/v2/records?id=123").to_return(body: { href: 'http://datastore/v2/records/123' }.to_json)
        Record.find(123)
      end

      it 'is also applicable to save' do
        stub_request(:post, 'http://datastore/v2/records/123').to_return(body: {}.to_json)
        expect(LHC).to receive(:request)
          .with(options.merge(method: :post, url: "http://datastore/v2/records/123", body: "{\"href\":\"http://datastore/v2/records/123\"}", headers: { "Content-Type" => "application/json" }))
          .and_call_original
        record.save(options)
      end

      it 'is also applicable to destroy' do
        stub_request(:delete, 'http://datastore/v2/records/123').to_return(body: {}.to_json)
        expect(LHC).to receive(:request)
          .with(options.merge(method: :delete, url: "http://datastore/v2/records/123"))
          .and_call_original
        record.destroy(options)
      end

      it 'is also applicable to update' do
        stub_request(:post, "http://datastore/v2/records/123").to_return(body: {}.to_json)
        expect(LHC).to receive(:request)
          .with(options.merge(method: :post, url: "http://datastore/v2/records/123", body: "{\"href\":\"http://datastore/v2/records/123\",\"name\":\"steve\"}", headers: { "Content-Type" => "application/json" }))
          .and_call_original
        record.update({ name: 'steve' }, options)
      end

      it 'is also applicable to valid?' do
        stub_request(:post, 'http://datastore/v2/records?persist=false').to_return(body: {}.to_json)
        expect(LHC).to receive(:request)
          .with(options.merge(url: ':datastore/records', method: :post, params: { persist: false }, body: "{\"href\":\"http://datastore/v2/records/123\"}", headers: { "Content-Type" => "application/json" }))
          .and_call_original
        record.valid?(options)
      end
    end
  end
end
