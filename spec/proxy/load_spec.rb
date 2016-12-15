require 'rails_helper'

describe LHS::Proxy do
  before(:each) do
    class Record < LHS::Record
      endpoint ':datastore/v2/feedbacks'
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

  let(:link) do
    item.campaign
  end

  before(:each) do
    stub_request(:get, 'http://local.ch/v2/content-ads/51dfc5690cf271c375c5a12d')
      .to_return(status: 200, body: load_json(:localina_content_ad))
  end

  context 'load' do
    it 'is loading data remotely when not present yet' do
      expect(link.load!.id).to be
      expect(link.id).to be
    end

    it 'can be reloaded' do
      expect(link.load!.id).to be
      stub_request(:get, 'http://local.ch/v2/content-ads/51dfc5690cf271c375c5a12d')
        .to_return(status: 404)
      expect(-> { link.reload!.id })
        .to raise_error LHC::NotFound
    end
  end

  context 'endpoint options' do
    before(:each) do
      class AnotherRecord < LHS::Record
        endpoint ':datastore/v2/feedbacks', params: { color: :blue }
      end
    end

    let(:record) do
      AnotherRecord.new(href: 'http://datastore/v2/feedbacks')
    end

    it 'applies endpoint options on load!' do
      stub_request(:get, 'http://datastore/v2/feedbacks?color=blue')
        .to_return(body: {}.to_json)
      record.load!
    end
  end

  context 'per request options' do
    let(:record) do
      Record.new(href: 'http://datastore/v2/feedbacks')
    end

    it 'applies options passed to load' do
      stub_request(:get, 'http://datastore/v2/feedbacks?color=blue')
        .to_return(body: {}.to_json)
      record.load!(params: { color: 'blue' })
    end
  end
end
