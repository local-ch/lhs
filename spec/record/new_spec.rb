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
      expect(feedback.instance_values['data'][:recommended]).to eq true
      expect(feedback.recommended).to eq true
      stub_request(:post, "http://local.ch/v2/feedbacks")
        .with(body: "{\"recommended\":true}")
      feedback.save
    end

    it 'builds new items also with keys containing dashes' do
      feedback = Feedback.new('some-key' => [])
      expect(feedback.instance_values['data']['some-key']).to eq []
    end

    it 'shows array in instance data' do
      feedback = Feedback.new([1, 2, 3])
      expect(feedback.instance_values['data']).to eq [1, 2, 3]
    end

    context 'custom setters' do
      before(:each) do
        class Feedback
          def ratings=(ratings)
            _raw[:ratings] = ratings.map { |_, v| v }
          end
        end
      end

      it 'are used by initializer' do
        feedback = Feedback.new(ratings: { a: 1, b: 2 })
        expect(feedback.instance_values['data'][:ratings]).to eq(a: 1, b: 2)
        expect(feedback.ratings.raw).to eq([1, 2])
      end
    end
  end
end
