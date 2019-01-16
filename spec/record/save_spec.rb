# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'save!' do
    context 'without href' do
      before do
        LHC.config.placeholder('datastore', datastore)
        class Feedback < LHS::Record
          endpoint '{+datastore}/content-ads/{campaign_id}/feedbacks'
        end
      end

      let(:datastore) { 'http://local.ch/v2' }
      let(:campaign_id) { 12345 }
      let(:object) { { recommended: true } }
      let(:item) { Feedback.new(object.merge(campaign_id: campaign_id)) }
      let!(:request) do
        stub_request(:post, "#{datastore}/content-ads/#{campaign_id}/feedbacks")
          .with(body: object.to_json)
          .to_return(status: 200, body: object.to_json)
      end

      it 'removes params used to compute url from send data' do
        item.save!
        expect(request).to have_been_made.once
      end

      context 'item without data' do
        let(:item) { Feedback.new(object) }

        it 'takes params to find endpoint also from the options' do
          item.save!(params: { campaign_id: campaign_id })
          expect(request).to have_been_made.once
        end
      end
    end
  end
end
