require 'rails_helper'

describe LHS::Proxy do

  before(:each) do
    class SomeService < LHS::Service
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

  let(:link) do
    item.campaign
  end

  before(:each) do
    stub_request(:get, 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/content-ads/51dfc5690cf271c375c5a12d')
      .to_return(status: 200, body: load_json(:localina_content_ad))
  end

  context 'load' do

    it 'is loading data remotely when not present yet' do
      link.load!.id
    end

    it 'can be reloaded' do
      link.load!.id
      stub_request(:get, 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/content-ads/51dfc5690cf271c375c5a12d')
        .to_return(status: 404)
      link.load!.id
      expect(-> { link.reload!.id })
        .to raise_error LHC::NotFound
    end
  end
end
