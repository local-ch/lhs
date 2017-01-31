require 'rails_helper'

describe LHS::Collection do
  let(:search) { 'http://local.ch/search' }
  let(:limit) { 10 }
  let(:total) { 20 }

  before(:each) do
    LHC.config.placeholder('search', search)
    class Search < LHS::Record
      configuration items_key: :docs, limit_key: :size, pagination_key: :start, pagination_strategy: :start, total_key: :totalResults
      endpoint ':search/:type'
    end
    stub_request(:get, "http://local.ch/search/phonebook?size=10").to_return(
      body: {
        docs: (1..10).to_a,
        start: 1,
        size: limit,
        totalResults: total
      }.to_json
    )
    stub_request(:get, "http://local.ch/search/phonebook?size=10&start=11").to_return(
      body: {
        docs: (11..20).to_a,
        start: 11,
        size: limit,
        totalResults: total
      }.to_json
    )
  end

  context 'lets you configure how to deal with collections' do
    it 'initalises and gives access to collections according to configuration' do
      results = Search.all(params: { type: :phonebook, size: 10 })
      expect(results.count).to eq total
      expect(results.total).to eq total
      expect(results.limit).to eq limit
      expect(results.offset).to eq 11
    end
  end
end
