# frozen_string_literal: true

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

  context 'explicit association class configuration overrules href class casting' do
    before do
      class Place < LHS::Record
        endpoint 'http://places/places/{id}'
        has_one :category, class_name: 'NewCategory'
      end

      class NewCategory < LHS::Record
        endpoint 'http://newcategories/newcategories/{id}'

        def name
          self['category_name']
        end
      end

      class Category < LHS::Record
        endpoint 'http://categories/categories/{id}'
      end

      stub_request(:get, "http://places/places/1")
        .to_return(body: {
          category: {
            href: 'https://categories/categories/1'
          }
        }.to_json)

      stub_request(:get, "https://categories/categories/1")
        .to_return(body: {
          href: 'https://categories/categories/1',
          category_name: 'Pizza'
        }.to_json)
    end

    it 'explicit association configuration overrules href class casting' do
      place = Place.includes(:category).find(1)
      expect(place.category).to be_kind_of NewCategory
      expect(place.category.name).to eq('Pizza')
    end
  end
end
