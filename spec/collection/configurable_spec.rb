require 'rails_helper'

describe LHS::Collection do
  let(:search) { 'http://local.ch/search' }
  let(:limit) { 10 }
  let(:total) { 20 }
  let(:offset) { 0 }
  let(:first_response_data) do
    {
      docs: (1..10).to_a,
      start: offset,
      size: limit,
      totalResults: total
    }
  end
  let(:second_response_data) do
    {
      docs: (11..20).to_a,
      start: offset,
      size: limit,
      totalResults: total
    }
  end

  before(:each) do
    LHC.config.placeholder('search', search)
    class Search < LHS::Record
      configuration items: :docs, limit: :size, offset: :start, total: :totalResults
      endpoint ':search/:type'
    end
    stub_request(:get, "http://local.ch/search/phonebook?size=10").to_return(body: first_response_data.to_json)
    stub_request(:get, "http://local.ch/search/phonebook?size=10&start=11").to_return(body: second_response_data.to_json)
  end

  context 'lets you configure how to deal with collections' do
    it 'initalises and gives access to collections according to configuration' do
      results = Search.all(type: :phonebook, size: 10)
      expect(results.count).to eq total
      expect(results.total).to eq total
      expect(results.limit).to eq limit
      expect(results.offset).to eq offset
    end
  end
end
