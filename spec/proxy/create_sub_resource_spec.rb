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
    let!(:create_review_request) do
      stub_request(:post, "http://datastore/v2/feedbacks/1/reviews")
        .to_return(body: {
          href: 'http://datastore/v2/feedbacks/1/reviews/1',
          title: 'Simply awesome'
        }.to_json)
    end

    context 'for a nested item' do
      let(:feedback) { Feedback.find(1) }
      let(:review) do
        feedback.review.create(
          title: 'Simply awesome'
        )
      end

      before do
        stub_request(:get, "http://datastore/v2/feedbacks/1/reviews")
          .to_return(body: {
            href: 'http://datastore/v2/feedbacks/1/reviews',
            title: 'Simply awesome'
          }.to_json)
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

        it 'creates an item' do
          review
          assert_requested(create_review_request)

          expect(feedback.review.title).to eq 'Simply awesome'
          expect(review.title).to eq 'Simply awesome'
        end
      end

      context 'with existing item' do
        before(:each) do
          stub_request(:get, "http://datastore/v2/feedbacks/1")
            .to_return(body: {
              review: {
                href: 'http://datastore/v2/feedbacks/1/reviews',
                title: 'Simply awesome'
              }
            }.to_json)
        end

        it 'raises error' do
          expect { review }.to raise_error(ArgumentError)

          assert_not_requested(create_review_request)
        end
      end
    end

    context 'for a nested collection' do
      let(:review) do
        feedback.reviews.create(
          title: 'Simply awesome'
        )
      end

      before do
        stub_request(:get, "http://datastore/v2/feedbacks/1/reviews")
          .to_return(body: {
            items: [{
              href: 'http://datastore/v2/feedbacks/1/reviews/1',
              title: 'Simply awesome'
            }]
          }.to_json)
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

      context 'when not expanded' do
        before(:each) do
          stub_request(:get, "http://datastore/v2/feedbacks/1")
            .to_return(body: {
              reviews: {
                href: 'http://datastore/v2/feedbacks/1/reviews'
              }
            }.to_json)
        end

        let(:feedback) { Feedback.find(1) }

        it 'creates an item' do
          review
          assert_requested(create_review_request)

          expect(feedback.reviews.first.title).to eq 'Simply awesome'
          expect(review.title).to eq 'Simply awesome'
        end
      end
    end
  end

  context 'error messages' do
    let!(:create_review_request) do
      stub_request(:post, "http://datastore/v2/feedbacks/1/reviews")
        .to_return(
          status: 400,
          body: {
            status: 400,
            message: 'Validation failed',
            field_errors: [{
              code: 'UNSATISFIED_PROPERTY_VALUE_MAXIMUM_LENGTH',
              path: ['title'],
              message: 'Title is too long'
            }]
          }.to_json
        )
    end

    let(:feedback) { Feedback.find(1) }
    let(:review) do
      feedback.review.create(
        title: 'Simply awesome'
      )
    end

    before do
      stub_request(:get, "http://datastore/v2/feedbacks/1")
        .to_return(body: {
          review: {
            href: 'http://datastore/v2/feedbacks/1/reviews'
          }
        }.to_json)
    end

    it 'are propagated when creation fails' do
      review
      assert_requested(create_review_request)

      expect(review.title).to eq 'Simply awesome'
      expect(review.errors.messages[:title]).to include('UNSATISFIED_PROPERTY_VALUE_MAXIMUM_LENGTH')
    end
  end
end
