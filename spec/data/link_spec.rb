require 'rails_helper'

describe LHS::Data do

  before(:each) do
    class SomeService < LHS::Service
      endpoint ':datastore/v2/feedbacks'
    end
  end

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    LHS::Data.new(json, nil, SomeService.instance)
  end

  let(:item) do
    data[0]
  end

  let(:link) do
    item.campaign
  end

  let(:stub_loading) do
    stub_request(:get, 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/content-ads/51dfc5690cf271c375c5a12d').
    to_return(status: 200, body: load_json(:localina_content_ad))
  end

  context 'link' do

    it 'is providing nested data if present already' do
      link.href
    end

    it 'is loading data remotely when not present yet' do
      stub_loading
      link.load!.id
    end

    it 'can be reloaded' do
      expect_any_instance_of(LHS::Link).to receive(:fetch).exactly(2).times.and_call_original
      stub_loading
      link.load!.id
      link.reload!.id
    end
  end
end
