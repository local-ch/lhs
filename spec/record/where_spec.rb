# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  let(:datastore) do
    'http://datastore/v2'
  end

  before do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint '{+datastore}/content-ads/{campaign_id}/feedbacks'
      endpoint '{+datastore}/feedbacks'
    end
  end

  context 'where' do
    it 'is querying relevant endpoint when using where' do
      stub_request(:get, "#{datastore}/feedbacks?has_review=true").to_return(status: 200, body: { items: [] }.to_json)
      Record.where(has_review: true)
      stub_request(:get, "#{datastore}/content-ads/123/feedbacks?has_review=true").to_return(status: 200, body: [].to_json)
      Record.where(campaign_id: '123', has_review: true)
      stub_request(:get, "#{datastore}/feedbacks").to_return(status: 200, body: [].to_json)
      records = Record.where
      expect(records).to be_kind_of Record
    end

    it 'is using params as query params explicitly when provided in params namespace' do
      stub_request(:get, "#{datastore}/content-ads/123/feedbacks?campaign_id=456").to_return(status: 200, body: [].to_json)
      Record.where(campaign_id: '123', params: { campaign_id: '456' })
    end

    context 'where with href' do
      let(:return_body) { [email: 'steve@local.ch'].to_json }

      context 'chain initialization' do
        before do
          stub_request(:get, "https://localch-accounts/?from_user_id=123")
            .to_return(body: return_body)
        end

        it 'queries api with provided href' do
          records = Record.where('https://localch-accounts?from_user_id=123').fetch
          expect(records.first.email).to eq 'steve@local.ch'
        end
      end

      context 'after chain initialization' do
        before do
          stub_request(:get, "https://localch-accounts/?color=blue&from_user_id=123")
            .to_return(body: return_body)
        end

        it 'queries api with provided href also when passed after chain is initialized' do
          records = Record.where(color: 'blue').where('https://localch-accounts?from_user_id=123').fetch
          expect(records.first.email).to eq 'steve@local.ch'
        end
      end
    end
  end
end
