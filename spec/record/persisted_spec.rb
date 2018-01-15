require 'rails_helper'

describe LHS::Record do
  context '#persisted?' do
    let(:datastore) { 'http://local.ch/v2' }

    before(:each) do
      LHC.config.placeholder('datastore', datastore)
      class Feedback < LHS::Record
        endpoint '{+datastore}/content-ads/{campaign_id}/feedbacks'
      end
    end

    context 'for new record' do
      context 'with a nil href' do
        subject { Feedback.new }

        it 'is false' do
          expect(subject.persisted?).to be(false)
        end
      end

      context 'with an empty href' do
        subject { Feedback.new(href: '') }

        it 'is false' do
          expect(subject.persisted?).to be(false)
        end
      end
    end

    context 'for saved record' do
      let(:campaign_id) { 'aaa' }
      let(:parameters) { { recommended: true } }
      subject { Feedback.new(parameters.merge(campaign_id: campaign_id)) }

      before do
        stub_request(:post, "#{datastore}/content-ads/#{campaign_id}/feedbacks")
          .with(body: parameters.to_json)
          .to_return(status: 200, body: parameters.merge(href: "#{datastore}/content-ads/#{campaign_id}/feedbacks/123456789").to_json)
      end

      it 'is true' do
        subject.save
        expect(subject.persisted?).to be(true)
      end
    end
  end
end
