require 'rails_helper'

describe LHS::Record do
  context 'new' do
    let(:datastore) { 'http://local.ch/v2' }

    before(:each) do
      LHC.config.placeholder('datastore', datastore)
      class Rating < LHS::Record
        endpoint ':datastore/content-ads/:campaign_id/feedbacks'
        endpoint ':datastore/feedbacks'
      end
    end

    it 'builds a new item from scratch (like build)' do
      feedback = Rating.new recommended: true
      expect(feedback).to be_kind_of Rating
      expect(feedback.recommended).to eq true
      stub_request(:post, "http://local.ch/v2/feedbacks")
        .with(body: "{\"recommended\":true}")
      feedback.save
    end

    it 'builds new items also with keys containing dashes' do
      feedback = Rating.new('some-key' => [])
      expect(feedback._raw[:'some-key']).to eq([])
    end

    context 'initialise records with raw data' do
      before(:each) do
        class User < LHS::Record
          endpoint ':datastore/users'
        end
      end

      it 'allows accessing nested data' do
        user = User.new({
          claims: {
            items: [
              { method: 'CustomerCenter' }
            ]
          }
        }.to_json)
        expect(user.claims.first['method']).to eq 'CustomerCenter'
      end
    end

    context 'custom setters' do
      before(:each) do
        class Rating
          def ratings=(ratings)
            _raw[:ratings] = ratings.map { |k, v| { name: k, value: v } }
          end
        end
      end

      it 'are used by initializer' do
        feedback = Rating.new(ratings: { a: 1, b: 2 })
        expect(feedback.ratings._raw).to eq([{ name: :a, value: 1 }, { name: :b, value: 2 }])
      end

      it 'can be used directly to change raw data' do
        feedback = Rating.new(ratings: { a: 1 })
        feedback.ratings = { z: 3 }
        expect(feedback.ratings.first.name).to eq :z
      end

      context 'that do not affect raw data' do
        before(:each) do
          class Rating
            attr_accessor :listing
          end
        end

        let(:listing) { double('listing') }

        it 'are used by initializer' do
          feedback = Rating.new(listing: listing)
          expect(feedback.listing).to eq(listing)
        end

        it 'do not set raw data' do
          feedback = Rating.new(listing: listing)
          expect(feedback._raw[:listing]).to be_nil
        end
      end

      context 'and custom getters' do
        before(:each) do
          class Rating
            def ratings
              Hash[_raw[:ratings].map { |r| [r[:name], r[:value]] }]
            end
          end
        end

        it 'uses custom getters to show data for exploration' do
          feedback = Rating.new(ratings: { a: 1, b: 2 })
          expect(feedback.ratings).to eq(a: 1, b: 2)
        end
      end
    end
  end
end
