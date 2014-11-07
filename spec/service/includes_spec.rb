require 'rails_helper'

describe LHS::Service do

  let(:datastore) { 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2' }
  before(:each) { LHC.config.placeholder('datastore', datastore) }

  context 'includes' do

    it 'links resources from two services' do

      class Feedback < LHS::Service
        endpoint ':datastore/feedbacks'
      end

      stub_request(:get, "#{datastore}/feedbacks?has_reviews=true")
      .to_return(status: 200, body: {
          items:[
            {
              "href" => "http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
              "campaign" => {
                "href" => "http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/content-ads/51dfc5690cf271c375c5a12d"
              }
            }
          ]
      }.to_json)

      stub_request(:get, "#{datastore}/content-ads/51dfc5690cf271c375c5a12d")
      .to_return(status: 200, body: {
         "href" => "http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/content-ads/51dfc5690cf271c375c5a12d",
         "entry" => {
           "href" => "http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/local-entries/lakj35asdflkj1203va"
         }
      }.to_json)

      stub_request(:get, "#{datastore}/local-entries/lakj35asdflkj1203va")
      .to_return(status: 200, body: {
         "name" => 'Casa Ferlin'
      }.to_json)

      feedbacks = Feedback.includes(campaign: :entry).where(has_reviews: true)
      expect(feedbacks.first.campaign.entry.name).to eq 'Casa Ferlin'
    end
  end
end
