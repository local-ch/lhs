require 'rails_helper'

describe LHS::Item do
  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint '{+datastore}/v2/{campaign_id}/feedbacks'
      endpoint '{+datastore}/v2/feedbacks'
    end
  end

  let(:datastore) do
    'http://local.ch'
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

  context 'destroy' do
    it 'destroys the item on the backend' do
      stub_request(:delete, "#{datastore}/v2/feedbacks/0sdaetZ-OWVg4oBiBJ-7IQ")
        .to_return(status: 200)
      expect(item.destroy._raw).to eq item._raw
    end

    it 'updates the request information on the item' do
      no_content = 204
      stub_request(:delete, "#{datastore}/v2/feedbacks/0sdaetZ-OWVg4oBiBJ-7IQ")
        .to_return(status: no_content)
      expect(item.destroy._request.response.code).to eq no_content
    end

    context 'includes and empty response' do
      before(:each) do
        class AnotherRecord < LHS::Record
          endpoint '{+datastore}/v2/:campaign_id/restaurants'
        end
      end

      it 'destroys an item even though it includes additonal services and an empty response body' do
        stub_request(:delete, "#{datastore}/v2/feedbacks/1")
          .to_return(status: 204, body: '')
        data = { href: "#{datastore}/v2/feedbacks/1", restaurant: { href: "#{datastore}/v2/restaurants/1" } }
        stub_request(:get, "#{datastore}/v2/feedbacks?id=1")
          .to_return(status: 200, body: data.to_json)
        stub_request(:get, "#{datastore}/v2/restaurants/1")
          .to_return(status: 200, body: { name: 'Casa Ferlin' }.to_json)
        item = Record.includes(:restaurant).find(1)
        item.destroy
      end
    end
  end
end
