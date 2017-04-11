require 'rails_helper'

describe LHS::Record do
  context 'url pattern' do
    let(:datastore) { 'http://local.ch/v2' }

    before(:each) do
      LHC.config.placeholder(:datastore, datastore)
      class Record < LHS::Record
        endpoint ':datastore/content-ads/:campaign_id/feedbacks'
        endpoint ':datastore/feedbacks'
      end
    end

    it 'is using params as query params explicitly when provided in params namespace' do
      request = stub_request(:get, "#{datastore}/content-ads/123/feedbacks?campaign_id=456").to_return(status: 200)
      Record.where(campaign_id: 123, params: { campaign_id: '456' }).to_a
      assert_requested(request)
    end
  end
end
