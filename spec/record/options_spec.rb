# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  let(:datastore) do
    'http://datastore/v2'
  end

  before do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint '{+datastore}/records', validates: { persist: false }
    end
  end

  let(:options) { { auth: { bearer: '123' }, validates: { persist: false } } }
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
        .with(options.merge(method: :post, url: "http://datastore/v2/records", body: { name: 'Steve' }, headers: {}))
        .and_call_original
      Record.options(options).create(name: 'Steve')
    end

    context 'actions on single records' do
      let!(:record) do
        stub_request(:get, "http://datastore/v2/records?id=123").to_return(body: { href: 'http://datastore/v2/records/123' }.to_json)
        Record.find(123)
      end

      context 'save' do
        before do
          stub_request(:post, 'http://datastore/v2/records/123').to_return(body: {}.to_json)
          expect(LHC).to receive(:request)
            .with(options.merge(method: :post, url: "http://datastore/v2/records/123", body: { href: 'http://datastore/v2/records/123' }, headers: {}))
            .and_call_original
        end

        it 'applies directly on save' do
          record.save(options)
        end

        it 'applies directly on save!' do
          record.save!(options)
        end

        it 'applies chaining them with save' do
          record.options(options).save
        end

        it 'applies chaining them with save!' do
          record.options(options).save!
        end
      end

      context 'destroy' do
        before do
          stub_request(:delete, 'http://datastore/v2/records/123').to_return(body: {}.to_json)
          expect(LHC).to receive(:request)
            .with(options.merge(method: :delete, url: "http://datastore/v2/records/123"))
            .and_call_original
        end

        it 'applies directly on destroy' do
          record.destroy(options)
        end

        it 'applies chaining them with destroy' do
          record.options(options).destroy
        end
      end

      context 'update' do
        before do
          stub_request(:post, "http://datastore/v2/records/123").to_return(body: {}.to_json)
          body = LHS::Data.new({ href: 'http://datastore/v2/records/123', name: 'steve' }, nil, Record)
          expect(LHC).to receive(:request)
            .with(options.merge(method: :post, url: "http://datastore/v2/records/123", body: body))
            .and_call_original
        end

        it 'applies directly on update' do
          record.update({ name: 'steve' }, options)
        end

        it 'applies directly on update!' do
          record.update!({ name: 'steve' }, options)
        end

        it 'applies chaining them with update' do
          record.options(options).update(name: 'steve')
        end

        it 'applies chaining them with update!' do
          record.options(options).update!(name: 'steve')
        end
      end

      context 'valid' do
        before do
          stub_request(:post, 'http://datastore/v2/records?persist=false').to_return(body: {}.to_json)
          body = LHS::Data.new({ href: 'http://datastore/v2/records/123' }, nil, Record)
          expect(LHC).to receive(:request)
            .with(options.merge(url: '{+datastore}/records', method: :post, params: { persist: false }, body: body))
            .and_call_original
        end

        it 'applies directly on valid' do
          record.valid?(options)
        end

        it 'applies chaining them with valid' do
          record.options(options).valid?
        end
      end
    end
  end
end
