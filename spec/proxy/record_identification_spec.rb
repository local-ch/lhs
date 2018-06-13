require 'rails_helper'

describe LHS::Proxy do
  before do
    class Search < LHS::Record
      endpoint 'http://search/results', items_key: :docs
    end

    class Feedback < LHS::Record
      endpoint 'http://datastore/places/{place_id}/feedbacks'
    end
  end

  context 'identifying records' do
    it 'identifies records correctly even if parent record has another configuration set' do
      stub_request(:get, "http://search/results?what=Blumen")
        .to_return(body: {
          place: { href: 'http://datastore/places/1' }
        }.to_json)
      stub_request(:get, "http://datastore/places/1")
        .to_return(body: {
          feedbacks: { href: 'http://datastore/places/1/feedbacks?limit=10&offset=0' }
        }.to_json)
      stub_request(:get, "http://datastore/places/1/feedbacks?limit=10&offset=0")
        .to_return(body: {
          items: [{ review: 'Nice restaurant' }]
        }.to_json)
      result = Search.where(what: 'Blumen').includes(place: :feedbacks)
      expect(result.place.feedbacks).to be_kind_of Feedback
      expect(result.place.feedbacks.first.review).to eq 'Nice restaurant'
    end
  end
end
