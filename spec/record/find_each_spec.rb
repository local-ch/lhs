require 'rails_helper'

describe LHS::Collection do
  let(:total) { 443 }

  let(:limit) { 100 }

  def api_response(ids, offset)
    records = ids.map { |i| { id: i } }
    {
      items: records,
      total: total,
      limit: limit,
      offset: offset
    }.to_json
  end

  let(:datastore) { 'http://local.ch/v2' }

  before do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint '{+datastore}/{campaign_id}/feedbacks'
      endpoint '{+datastore}/feedbacks'
    end
  end

  context 'find_each' do
    it 'processes each record by fetching records in batches' do
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=1").to_return(status: 200, body: api_response((1..100).to_a, 1))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=101").to_return(status: 200, body: api_response((101..200).to_a, 101))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=201").to_return(status: 200, body: api_response((201..300).to_a, 201))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=301").to_return(status: 200, body: api_response((301..400).to_a, 301))
      stub_request(:get, "#{datastore}/feedbacks?limit=100&offset=401").to_return(status: 200, body: api_response((401..total).to_a, 401))
      count = 0
      Record.find_each do |record|
        count += 1
        expect(record.id).to eq(count)
        expect(record).to be_kind_of Record
        expect(record._proxy).to be_kind_of LHS::Item
      end
      expect(count).to eq total
    end

    it 'passes options to the requests made' do
      request = stub_request(:get, "http://local.ch/v2/feedbacks?limit=100&offset=1")
        .with(headers: {'Authorization' => 'Bearer 123'})
        .to_return(body: {
          items: []
        }.to_json)
      Record.find_each(headers: { 'Authorization' => 'Bearer 123' }) {|record| }
      expect(request).to have_been_made
    end
  end
end
