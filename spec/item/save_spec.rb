# frozen_string_literal: true

require 'rails_helper'

describe LHS::Item do
  before do
    class Record < LHS::Record
      endpoint '{+datastore}/v2/{campaign_id}/feedbacks'
      endpoint '{+datastore}/v2/feedbacks'
    end
  end

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    LHS::Data.new(json, nil, Record)
  end

  let(:item) do
    data[0]
  end

  context 'endpoint options' do
    let(:headers) { { 'X-Header' => 'VALUE' } }

    before do
      class RecordWithOptions < LHS::Record
        endpoint 'http://datastore/records', headers: { 'X-Header' => 'VALUE' }
      end
    end

    it 'considers end point options when saving' do
      data = { name: 'Steve' }
      stub_request(:post, "http://datastore/records")
        .with(body: data.to_json, headers: headers)
        .to_return(body: data.to_json)
      RecordWithOptions.create!(data)
    end
  end

  context 'save' do
    it 'persists changes on the backend' do
      stub_request(:post, item.href).with(body: item._raw.merge(name: 'Steve').to_json)
      item.name = 'Steve'
      expect(item.save).to eq true
    end

    it 'returns false if persting goes wrong' do
      stub_request(:post, item.href)
        .with(body: item._raw.to_json)
        .to_return(status: 500)
      expect(item.save).to eq false
    end

    it 'merges reponse data with object' do
      stub_request(:post, item.href)
        .with(body: item._raw.to_json)
        .to_return(status: 200, body: item._raw.merge(name: 'Steve').to_json)
      item.save
      expect(item.name).to eq 'Steve'
    end
  end

  context 'with many placeholders' do
    before do
      class GrandChild < LHS::Record
        endpoint 'http://host/v2/parents/{parent_id}/children/{child_id}/grand_children'
        endpoint 'http://host/v2/parents/{parent_id}/children/{child_id}/grand_children/{id}'
      end
    end

    let(:data) do
      {
        parent_id: "bbb",
        child_id: 'ccc',
        name: "Lorem"
      }
    end

    let(:item) do
      GrandChild.new(data)
    end

    it 'persists changes on the backend' do
      stub_request(:post, 'http://host/v2/parents/bbb/children/ccc/grand_children')
        .with(body: { name: "Lorem" }.to_json)

      expect(item.save).to eq true
    end
  end

  context 'save!' do
    it 'raises if something goes wrong' do
      stub_request(:post, item.href)
        .with(body: item._raw.to_json)
        .to_return(status: 500)
      expect(-> { item.save! }).to raise_error LHC::ServerError
    end

    it 'keeps header psassed in the options' do
      headers = { 'Stats' => 'first-access' }
      request = stub_request(:post, item.href)
        .with(
          body: item._raw.to_json,
          headers: headers
        )
        .to_return(status: 200, body: item._raw.to_json)

      item.save!(headers: headers)
      expect(request).to have_been_requested
    end
  end

  context 'chainable' do
    it 'allows to chain save with options' do
      stub_request(:put, item.href).with(body: item._raw.merge(name: 'Steve').to_json)
      item.name = 'Steve'
      result = item.options(method: :put).save

      expect(result).to eq true
    end
  end
end
