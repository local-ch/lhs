require 'rails_helper'

describe LHS::Item do
  before(:each) do
    class Feedback < LHS::Record
      endpoint 'http://datastore/v2/feedbacks/:id'
    end
    class Review < LHS::Record
      endpoint 'http://datastore/v2/feedbacks/:feedback_id/reviews'
    end
  end

  context 'create sub-resource' do
    before(:each) do
      stub_request(:get, "http://datastore/v2/feedbacks/1")
        .to_return(body: {
          reviews: {
            href: 'http://datastore/v2/feedbacks/1/reviews'
          }
        }.to_json)
    end
    let!(:create_review_request) do
      stub_request(:post, "http://datastore/v2/feedbacks/1/reviews")
        .to_return(body: {
          thumbs: 'up'
        }.to_json)
    end
    it 'creates a sub resource through root item' do
      feedback = Feedback.find(1)
      review = feedback.reviews.create(
        thumbs: 'up'
      )
      assert_requested(create_review_request)
      binding.pry
      expect(feedback.reviews.first.thumbs).to eq 'up'
      expect(review.thumbs).to eq 'up'
    end
  end
end
