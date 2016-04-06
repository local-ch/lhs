require 'rails_helper'

describe LHS::Record do
  context 'new' do
    let(:datastore) { 'http://local.ch/v2' }

    before(:each) do
      LHC.config.placeholder('datastore', datastore)
      class Feedback < LHS::Record
        endpoint ':datastore/content-ads/:campaign_id/feedbacks'
        endpoint ':datastore/feedbacks'
      end
    end

    it 'builds a new item from scratch (like build)' do
      feedback = Feedback.new recommended: true
      expect(feedback).to be_kind_of Feedback
      expect(feedback.recommended).to eq true
      stub_request(:post, "http://local.ch/v2/feedbacks")
        .with(body: "{\"recommended\":true}")
      feedback.save
    end

    it 'builds new items also with keys containing dashes' do
      feedback = Feedback.new('some-key' => [])
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
        class Feedback
          def ratings=(ratings)
            _raw[:ratings] = ratings.map { |k, v| { name: k, value: v } }
          end
        end
      end

      it 'are used by initializer' do
        feedback = Feedback.new(ratings: { a: 1, b: 2 })
        expect(feedback.ratings.raw).to eq([{ name: :a, value: 1 }, { name: :b, value: 2 }])
      end

      it 'can be used directly to change raw data' do
        feedback = Feedback.new(ratings: { a: 1 })
        feedback.ratings = { z: 3 }
        expect(feedback.ratings.first.name).to eq :z
      end

      context 'and custom getters' do
        before(:each) do
          class Feedback
            def ratings
              Hash[_raw[:ratings].map { |r| [r[:name], r[:value]] }]
            end
          end
        end

        it 'uses custom getters to show data for exploration' do
          feedback = Feedback.new(ratings: { a: 1, b: 2 })
          expect(feedback.ratings).to eq(a: 1, b: 2)
        end
      end
    end
  end
end
