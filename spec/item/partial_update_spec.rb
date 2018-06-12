require 'rails_helper'

describe LHS::Item do
  before(:each) do
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

  context 'update' do
    it 'persists changes on the backend' do
      stub_request(:post, item.href)
        .with(body: { name: 'Steve' }.to_json)
      result = item.partial_update(name: 'Steve')
      expect(result).to eq true
    end

    it 'returns false if persisting went wrong' do
      stub_request(:post, item.href).to_return(status: 500)
      result = item.partial_update(name: 'Steve')
      expect(result).to eq false
    end

    it 'merges reponse data with object' do
      stub_request(:post, item.href)
        .to_return(status: 200, body: item._raw.merge(likes: 'Banana').to_json)
      item.partial_update(name: 'Steve')
      expect(item.name).to eq 'Steve'
      expect(item.likes).to eq 'Banana'
    end

    it 'updates local version of an object even if BE request fails' do
      stub_request(:post, item.href)
        .to_return(status: 400, body: item._raw.merge(likes: 'Banana').to_json)
      item.update(name: 'Andrea')
      expect(item.name).to eq 'Andrea'
      expect(item.likes).not_to eq 'Banana'
    end
  end

  context 'update!' do
    it 'raises if something goes wrong' do
      stub_request(:post, item.href)
        .with(body: { name: 'Steve' }.to_json)
        .to_return(status: 500)
      expect(-> { item.partial_update!(name: 'Steve') }).to raise_error LHC::ServerError
    end
  end

  context 'records without hrefs and nested items' do

    before(:each) do
      class Location < LHS::Record
        endpoint 'http://uberall/locations'
        endpoint 'http://uberall/locations/{id}'
      end
    end

    it 'finds and compiles existing endpoints to determine update url' do
      stub_request(:get, "http://uberall/locations/1").to_return(body: { id: 1 }.to_json)
      stub_request(:post, "http://uberall/locations/1").to_return(body: { id: 1, listings: [{ directory: 'facebook' }] }.to_json)
      location = Location.find(1)
      location.partial_update(autoSync: true)
      expect(location.autoSync).to eq true
      expect(location.listings.first.directory).to eq 'facebook'
    end

    context 'records with nested items' do

      before(:each) do
        class Location < LHS::Record
          endpoint 'http://uberall/locations'
          endpoint 'http://uberall/locations/{id}'
          configuration item_created_key: [:response, :location], item_key: [:response, :location]
        end
      end

      it 'finds and compiles existing endpoints to determine update url' do
        stub_request(:get, "http://uberall/locations/1").to_return(body: { response: { location: { id: 1 } } }.to_json)
        stub_request(:post, "http://uberall/locations/1").to_return(body: { response: { location: { id: 1, listings: [{ directory: 'facebook' }] } } }.to_json)
        location = Location.find(1)
        location.partial_update(autoSync: true)
        expect(location.autoSync).to eq true
        expect(location.listings.first.directory).to eq 'facebook'
      end

      it 'use given update http method' do
        stub_request(:get, "http://uberall/locations/1").to_return(body: { response: { location: { id: 1 } } }.to_json)
        stub_request(:patch, "http://uberall/locations/1").to_return(body: { response: { location: { id: 1, listings: [{ directory: 'facebook' }] } } }.to_json)
        location = Location.find(1)
        location.partial_update({ autoSync: true }, { method: :patch })
        expect(location.autoSync).to eq true
        expect(location.listings.first.directory).to eq 'facebook'
      end
    end
  end
end
