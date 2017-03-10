require 'rails_helper'

describe LHS::Record do
  let(:datastore) { 'http://local.ch/v2' }

  before(:each) do
    LHC.config.placeholder(:datastore, datastore)
    class Record < LHS::Record
      endpoint ':datastore/content-ads/:campaign_id/feedbacks'
      endpoint ':datastore/content-ads/:campaign_id/feedbacks/:id'
      endpoint ':datastore/feedbacks'
      endpoint ':datastore/feedbacks/:id'
    end
  end

  context 'find' do
    context 'finds a single unique record' do
      before(:each) do
        stub_request(:get, "#{datastore}/feedbacks/z12f-3asm3ngals")
          .to_return(status: 200, body: load_json(:feedback))
      end

      it 'by id' do
        record = Record.find('z12f-3asm3ngals')
        expect(record).to be_kind_of Record
        expect(record.source_id).to be_kind_of String
      end

      it 'by href' do
        record = Record.find("#{datastore}/feedbacks/z12f-3asm3ngals")
        expect(record).to be_kind_of Record
        expect(record.source_id).to be_kind_of String
      end
    end

    it 'raises if nothing was found' do
      stub_request(:get, "#{datastore}/feedbacks/not-existing")
        .to_return(status: 404)
      expect { Record.find('not-existing') }.to raise_error LHC::NotFound
    end

    it 'finds unique item by providing parameters' do
      stub_request(:get, "#{datastore}/content-ads/123/feedbacks/123")
        .to_return(body: "{}")
      data = Record.find(campaign_id: '123', id: '123')
      expect(data._proxy).to be_kind_of LHS::Item
    end

    it 'returns item in case of backend returning collection' do
      data = JSON.parse(load_json(:feedbacks))
      data['items'] = [data['items'].first]
      stub_request(:get, "#{datastore}/content-ads/123/feedbacks/123")
        .to_return(body: data.to_json)
      data = Record.find(campaign_id: '123', id: '123')
      expect(data._proxy).to be_kind_of LHS::Item
    end

    it 'fails when multiple items where found by parameters' do
      stub_request(:get, "#{datastore}/content-ads/123/feedbacks/123")
        .to_return(body: load_json(:feedbacks))
      expect(lambda {
        Record.find(campaign_id: '123', id: '123')
      }).to raise_error LHC::NotFound
    end

    it 'fails when no item as found by parameters' do
      data = JSON.parse(load_json(:feedbacks))
      data['items'] = []
      stub_request(:get, "#{datastore}/content-ads/123/feedbacks/123")
        .to_return(body: data.to_json)
      expect(lambda {
        Record.find(campaign_id: '123', id: '123')
      }).to raise_error LHC::NotFound
    end

    it 'raises if nothing was found with parameters' do
      stub_request(:get, "#{datastore}/content-ads/123/feedbacks/123")
        .to_return(status: 404)
      expect { Record.find(campaign_id: '123', id: '123') }.to raise_error LHC::NotFound
    end
  end
end
