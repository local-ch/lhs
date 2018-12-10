require 'rails_helper'

describe LHS::Record do

  let(:transaction) { Transaction.find(1) }
  let(:user) { transaction.user }

  before do
    [1, 2].each do |id|
      stub_request(:get, "http://myservice/transactions/#{id}")
        .to_return(body: {
          user: {
            email_address: 'steve@local.ch',
            comments: []
          }
        }.to_json)
    end
  end

  context 'has_one' do

    before do
      class Transaction < LHS::Record
        endpoint 'http://myservice/transactions'
        endpoint 'http://myservice/transactions/{id}'
        has_one :user
      end

      class User < LHS::Record
        has_many :comments

        def email
          self[:email_address]
        end
      end

      class Comment < LHS::Record
      end
    end

    it 'casts the relation into the correct type' do
      expect(user).to be_kind_of(User)
      expect(user.email).to eq 'steve@local.ch'
    end

    it 'keeps hirachy when casting it to another class on access' do
      expect(user._root._raw).to eq transaction._raw
      expect(user.parent._raw).to eq transaction._raw
    end

    it 'caches the relation in memory' do
      allow(LHS::Record).to receive(:for_url).and_return(User)
      user_object_id = transaction.user.object_id
      expect(transaction.user.object_id).to eql(user_object_id)
      transaction2 = Transaction.find(2)
      expect(transaction2.user.object_id).not_to eql(user_object_id)
    end

    it 'recalculates cache for relation when it was modified' do
      allow(LHS::Record).to receive(:for_url).and_return(Comment)
      expect(user.comments).to be_blank
      comments_object_id = user.comments.object_id
      user.comments = [Comment.new]
      expect(user.comments.object_id).not_to eql(comments_object_id)
      expect(user.comments).not_to be_blank
    end
  end

  context 'custom class_name' do

    before do
      class Transaction < LHS::Record
        endpoint 'http://myservice/transactions'
        endpoint 'http://myservice/transactions/{id}'
        has_one :user, class_name: 'Custom::User'
      end

      module Custom
        class User < LHS::Record
          def email
            self[:email_address]
          end
        end
      end
    end

    it 'casts the relation into the correct type' do
      expect(user).to be_kind_of(Custom::User)
      expect(user.email).to eq 'steve@local.ch'
    end
  end
end
