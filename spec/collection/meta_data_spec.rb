require 'rails_helper'

describe LHS::Collection do

  let(:total) { 0 }

  let(:limit) { 50 }

  let(:offset) { 0 }

  let(:response) do
    {
      items: [],
      total: total,
      limit: limit,
      offset: offset
    }.to_json
  end

  let(:datastore) { 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2' }

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Feedback < LHS::Service
      endpoint ':datastore/feedbacks'
    end
  end

  it 'provides meta data for collections' do
    stub_request(:get, "#{datastore}/feedbacks").to_return(status: 200, body: response)
    feedbacks = Feedback.where
    expect(feedbacks.total).to eq total
    expect(feedbacks.limit).to eq limit
    expect(feedbacks.offset).to eq offset
  end
end
