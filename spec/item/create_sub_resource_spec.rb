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

  let!(:create_review_request) do
    stub_request(:post, "http://datastore/v2/feedbacks/1/reviews")
      .to_return(body: {
        title: 'Simply awesome'
      }.to_json)
  end

  context 'create sub-resource' do
    context 'for a nested item' do
      let(:feedback) { Feedback.find(1) }
      let(:review) do
        feedback.review.create(
          title: 'Simply awesome'
        )
      end

      context 'without the object' do
        before(:each) do
          stub_request(:get, "http://datastore/v2/feedbacks/1")
            .to_return(body: {
              review: {
                href: 'http://datastore/v2/feedbacks/1/reviews'
              }
            }.to_json)
        end
    end
  end
end
