require 'rails_helper'

describe LHS::Record do
  let(:user_item) do
    {
      email: 'someone@somewhe.re'
    }
  end

  let(:item) do
    {
      href: 'http://datastore/records/1',
      user: user_item
    }
  end

  let(:record) { Record.find(1) }

  before do
    class User < LHS::Record
    end

    class Record < LHS::Record
      endpoint 'http://datastore/records/{id}'

      has_one :user, class_name: 'User'
    end

    stub_request(:get, 'http://datastore/records/1')
      .to_return(body: item.to_json)
  end

  describe 'respond_to?(:to_ary)' do
    context 'when creating item' do
      let(:record) do
        Record.new(user: User.new)
      end

      it 'does not respond to to_ary' do
        expect(record.user.respond_to?(:to_ary)).to eq false
      end
    end

    context 'when returning a single item' do
      it 'does not respond to to_ary' do
        expect(record.user.respond_to?(:to_ary)).to eq false
      end
    end

    context 'when returning array of items' do
      let(:user_item) do
        [
          { email: 'someone@somewhe.re' },
          { email: 'someone.else@somewhe.re' }
        ]
      end

      it 'responds to to_ary' do
        expect(record.user.respond_to?(:to_ary)).to eq true
      end
    end
  end
end
