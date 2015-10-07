require 'rails_helper'

describe LHS::Service do

  let(:datastore) { 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2' }
  before(:each) { LHC.config.placeholder('datastore', datastore) }

  let(:stub_campaign_request) do
    stub_request(:get, "#{datastore}/content-ads/51dfc5690cf271c375c5a12d")
      .to_return(body: {
        'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d",
        'entry' => { 'href' => "#{datastore}/local-entries/lakj35asdflkj1203va" }
      }.to_json)
  end

  let(:stub_entry_request) do
    stub_request(:get, "#{datastore}/local-entries/lakj35asdflkj1203va")
      .to_return(body: { 'name' => 'Casa Ferlin' }.to_json)
  end

  context 'includes' do

    before(:each) do
      class Feedback < LHS::Service
        endpoint ':datastore/feedbacks'
        endpoint ':datastore/feedbacks/:id'
      end
      stub_campaign_request
      stub_entry_request
    end

    it 'includes linked resources while fetching multiple resources from one service' do

      stub_request(:get, "#{datastore}/feedbacks?has_reviews=true")
        .to_return(status: 200, body: {
          items: [
            {
              'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
              'campaign' => { 'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d" }
            }
          ]
        }.to_json)

      feedbacks = Feedback.includes(campaign: :entry).where(has_reviews: true)
      expect(feedbacks.first.campaign.entry.name).to eq 'Casa Ferlin'
    end

    it 'includes linked resources while fetching a single resource from one service' do

      stub_request(:get, "#{datastore}/feedbacks/123")
        .to_return(status: 200, body: {
          'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
          'campaign' => { 'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d" }
        }.to_json)

      feedbacks = Feedback.includes(campaign: :entry).find(123)
      expect(feedbacks.campaign.entry.name).to eq 'Casa Ferlin'
    end

    context 'include objects from known services' do

      let(:stub_feedback_request) do
        stub_request(:get, "#{datastore}/feedbacks")
          .to_return(status: 200, body: {
              items: [
                {
                  'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
                  'entry' => {
                    'href' => "#{datastore}/local-entries/lakj35asdflkj1203va"
                  }
                }
              ]
          }.to_json)
      end

      before(:each) do
        class Entry < LHS::Service
          endpoint ':datastore/local-entries/:id'
        end
        class SomeInterceptor < LHC::Interceptor; end
        LHC.config.interceptors = [SomeInterceptor]
      end

      it 'uses interceptors for included links from known services' do
        stub_feedback_request
        stub_entry_request

        @called = 0
        allow_any_instance_of(SomeInterceptor).to receive(:before_request) { @called += 1 }

        expect(Feedback.includes(:entry).where.first.entry.name).to eq 'Casa Ferlin'
        expect(@called).to eq 2
      end
    end
  end
end
