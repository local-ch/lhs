require 'rails_helper'

describe LHS::Record do

  let(:transaction) { Transaction.find(1) }
  let(:user) { transaction.user }

  before do
    stub_request(:get, 'http://myservice/transactions/1')
      .to_return(body: {
        user: {
          email_address: 'steve@local.ch'
        }
      }.to_json)
  end

  context 'has_one' do

    before do
      class Transaction < LHS::Record
        endpoint 'http://myservice/transactions'
        endpoint 'http://myservice/transactions/{id}'
        has_one :user
      end

      class User < LHS::Record

        def email
          self[:email_address]
        end
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
