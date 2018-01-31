require 'rails_helper'

describe LHS::Collection do
  let(:total) { 443 }

  let(:limit) { 100 }

  def api_response(ids, offset, options = {})
    records = ids.map { |i| { id: i } }
    {
      options.fetch(:items_key, :items) => records,
      options.fetch(:total_key, :total) => total,
      options.fetch(:limit_key, :limit) => limit,
      options.fetch(:pagination_key, :offset) => offset
    }.to_json
  end

  let(:datastore) { 'http://local.ch/v2' }

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint '{+datastore}/{campaign_id}/feedbacks'
      endpoint '{+datastore}/feedbacks'
    end
  end

  context 'find_batches' do
    it 'processes records in batches' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=1").to_return(status: 200, body: api_response((1..100).to_a, 1))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=101").to_return(status: 200, body: api_response((101..200).to_a, 101))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=201").to_return(status: 200, body: api_response((201..300).to_a, 201))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=301").to_return(status: 200, body: api_response((301..400).to_a, 301))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=401").to_return(status: 200, body: api_response((401..total).to_a, 401))
      length = 0
      Record.find_in_batches do |records|
        length += records.length
        expect(records).to be_kind_of Record
        expect(records._proxy).to be_kind_of LHS::Collection
      end
      expect(length).to eq total
    end

    it 'adapts to backend max limit' do
      stub_request(:get, "#{datastore}/feedbacks?limit=230&offset=1").to_return(status: 200, body: api_response((1..100).to_a, 1))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=101").to_return(status: 200, body: api_response((101..200).to_a, 101))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=201").to_return(status: 200, body: api_response((201..300).to_a, 201))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=301").to_return(status: 200, body: api_response((301..400).to_a, 301))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=401").to_return(status: 200, body: api_response((401..total).to_a, 401))
      length = 0
      Record.find_in_batches(batch_size: 230) do |records|
        length += records.length
        expect(records).to be_kind_of Record
        expect(records._proxy).to be_kind_of LHS::Collection
      end
      expect(length).to eq total
    end

    it 'forwards offset' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=401").to_return(status: 200, body: api_response((401..total).to_a, 401))
      Record.find_in_batches(start: 401) do |records|
        expect(records.length).to eq(total - 400)
      end
    end
  end

  context 'configured pagination' do
    before(:each) do
      class Record < LHS::Record
        endpoint '{+datastore}/{campaign_id}/feedbacks'
        endpoint '{+datastore}/feedbacks'
        configuration items_key: 'docs', limit_key: 'size', pagination_key: 'start', pagination_strategy: 'start', total_key: 'totalResults'
      end
    end

    let(:options) { { items_key: 'docs', limit_key: 'size', pagination_key: 'start', total_key: 'totalResults' } }

    it 'capable to do batch processing with configured pagination' do
      stub_request(:get, "#{datastore}/feedbacks?size=230&start=1").to_return(status: 200, body: api_response((1..100).to_a, 1, options))
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=101").to_return(status: 200, body: api_response((101..200).to_a, 101, options))
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=201").to_return(status: 200, body: api_response((201..300).to_a, 201, options))
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=301").to_return(status: 200, body: api_response((301..400).to_a, 301, options))
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=401").to_return(status: 200, body: api_response((401..total).to_a, 401, options))
      length = 0
      Record.find_in_batches(batch_size: 230) do |records|
        length += records.length
        expect(records).to be_kind_of Record
        expect(records._proxy).to be_kind_of LHS::Collection
      end
      expect(length).to eq total
    end
  end

  context 'pagination with nested response' do
    before do
      class Record < LHS::Record
        endpoint '{+datastore}/{campaign_id}/feedbacks'
        endpoint '{+datastore}/feedbacks'
        configuration items_key: [:response, :docs], limit_key: { body: [:response, :size], parameter: :size }, pagination_key: { body: [:response, :start], parameter: :start }, pagination_strategy: :start, total_key: [:response, :totalResults]
      end
    end

    let(:options) { { items_key: 'docs', limit_key: 'size', pagination_key: 'start', total_key: 'totalResults' } }

    it 'capable to do batch processing with configured pagination' do
      stub_request(:get, "#{datastore}/feedbacks?size=230&start=1").to_return(status: 200, body: "{\"response\":#{api_response((1..100).to_a, 1, options)}}")
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=101").to_return(status: 200, body: "{\"response\":#{api_response((101..200).to_a, 101, options)}}")
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=201").to_return(status: 200, body: "{\"response\":#{api_response((201..300).to_a, 201, options)}}")
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=301").to_return(status: 200, body: "{\"response\":#{api_response((301..400).to_a, 301, options)}}")
      stub_request(:get, "#{datastore}/feedbacks?size=100&start=401").to_return(status: 200, body: "{\"response\":#{api_response((401..total).to_a, 401, options)}}")
      length = 0
      Record.find_in_batches(batch_size: 230) do |records|
        length += records.length
        expect(records).to be_kind_of Record
        expect(records._proxy).to be_kind_of LHS::Collection
      end
      expect(length).to eq total
    end
  end
end
