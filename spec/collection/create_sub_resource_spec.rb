require 'rails_helper'

describe LHS::Collection do
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
    context 'for a nested collection' do
      let(:review) do
        feedback.reviews.create(
          title: 'Simply awesome'
        )
      end

      context 'when expanded' do
        before(:each) do
          stub_request(:get, "http://datastore/v2/feedbacks/1")
            .to_return(body: {
              reviews: {
                href: 'http://datastore/v2/feedbacks/1/reviews',
                items: []
              }
            }.to_json)
        end

        let(:feedback) { Feedback.includes(:reviews).find(1) }

        it 'creates an item' do
          review
          assert_requested(create_review_request)

          expect(feedback.reviews.first.title).to eq 'Simply awesome'
          expect(review.title).to eq 'Simply awesome'
        end
      end
    end
  end
end
