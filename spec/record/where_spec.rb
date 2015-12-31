require 'rails_helper'

describe LHS::Record do

  let(:datastore) do
    'http://datastore/v2'
  end

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint ':datastore/v2/content-ads/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end

  context 'where' do

    it 'is querying relevant endpoint when using where' do
      stub_request(:get, "#{datastore}/v2/feedbacks?has_review=true").to_return(status: 200)
      Record.where(has_review: true)
      stub_request(:get, "#{datastore}/v2/content-ads/123/feedbacks?has_review=true").to_return(status: 200)
      Record.where(campaign_id: '123', has_review: true)
      stub_request(:get, "#{datastore}/v2/feedbacks").to_return(status: 200, body: '')
      Record.where
    end

    it 'is using params as query params explicitly when provided in params namespace' do
      stub_request(:get, "#{datastore}/v2/content-ads/123/feedbacks?campaign_id=456").to_return(status: 200)
      Record.where(campaign_id: '123', params: { campaign_id: '456' })
    end
  end
end
