require 'rails_helper'

describe LHS::Item do

  before(:each) do
    class SomeService < LHS::Service
      endpoint ':datastore/v2/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    LHS::Data.new(json, nil, SomeService)
  end

  let(:item) do
    data[0]
  end

  context 'update' do

    it 'persists changes on the backend' do
      stub_request(:post, item.href)
      .with(body: item._raw.merge(name: 'Steve').to_json)
      result = item.update(name: 'Steve')
      expect(result).to eq true
    end

    it 'returns false if persisting went wrong' do
      stub_request(:post, item.href).to_return(status: 500)
      result = item.update(name: 'Steve')
      expect(result).to eq false
    end

    it 'merges reponse data with object' do
      stub_request(:post, item.href)
      .to_return(status: 200, body: item._raw.merge(likes: 'Banana').to_json)
      item.update(name: 'Steve')
      expect(item.likes).to eq 'Banana'
    end
  end

  context 'update!' do

    it 'raises if something goes wrong' do
      stub_request(:post, item.href)
      .with(body: item._raw.merge(name: 'Steve').to_json)
      .to_return(status: 500)
      expect(->{ item.update!(name: 'Steve') }).to raise_error LHC::ServerError
    end
  end
end
