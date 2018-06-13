require 'rails_helper'

describe LHS::Item do
  let(:user) do
    User.build(email: 'steve@local.ch')
  end

  let(:record) do
    Record.build(number: '123456')
  end

  context 'deprecation warning for old syntax' do
    it 'throws errors when using validates with the old syntax' do
      expect(lambda do
        class User < LHS::Record
          endpoint 'http://datastore/v2/users', validates: true
        end
      end).to raise_error 'Validates with either true or a simple string is deprecated! See here: https://github.com/local-ch/lhs#validation'
      expect(lambda do
        class Record < LHS::Record
          endpoint 'http://datastore/v2/records', validates: 'publish'
        end
      end).to raise_error 'Validates with either true or a simple string is deprecated! See here: https://github.com/local-ch/lhs#validation'
    end
  end

  context 'passing validation parameters' do
    let(:user) do
      User.build(email: 'steve@local.ch')
    end

    it 'validates {publish: false}' do
      class User < LHS::Record
        endpoint 'http://datastore/v2/users', validates: { params: { publish: false } }
      end
      stub_request(:post, "http://datastore/v2/users?publish=false").to_return(body: {}.to_json)
      expect(user.valid?).to eq true
    end

    it 'validates {persist: false}' do
      class User < LHS::Record
        endpoint 'http://datastore/v2/users', validates: { params: { persist: false } }
      end
      stub_request(:post, "http://datastore/v2/users?persist=false").to_return(body: {}.to_json)
      expect(user.valid?).to eq true
    end

    it 'validates {validates: true}' do
      class User < LHS::Record
        endpoint 'http://datastore/v2/users', validates: { params: { validates: true } }
      end
      stub_request(:post, "http://datastore/v2/users?validates=true").to_return(body: {}.to_json)
      expect(user.valid?).to eq true
    end

    it 'validates /validate' do
      class User < LHS::Record
        endpoint 'http://datastore/v2/users', validates: { path: 'validate' }
      end
      stub_request(:post, "http://datastore/v2/users/validate").to_return(body: {}.to_json)
      expect(user.valid?).to eq true
    end
  end

  context 'errors object' do
    let(:validation_errors) { { field_errors: [{ code: "UNSUPPORTED_PROPERTY_VALUE", "path" => ["email"] }] } }
    let(:successful_validation) do
      stub_request(:post, "http://datastore/v2/users?persist=false").to_return(body: {}.to_json)
    end
    let(:failing_validation) do
      stub_request(:post, "http://datastore/v2/users?persist=false")
        .to_return(status: 400, body: validation_errors.to_json)
    end

    before do
      class User < LHS::Record
        endpoint 'http://datastore/v2/users', validates: { params: { persist: false } }
      end
    end

    it 'provides validation errors through the error object' do
      successful_validation
      expect(user.valid?).to eq true
      user.email = 'not a valid email'
      failing_validation
      expect(user.valid?).to eq false
      expect(user.errors[:email]).to be_present
    end

    it 'gets reset when revalidation' do
      failing_validation
      expect(user.valid?).to eq false
      user.email = 'steve@local.ch'
      successful_validation
      expect(user.valid?).to eq true
      expect(user.errors.messages).to be_empty
    end
  end

  context 'endpoint does not support validations' do
    before do
      class Favorite < LHS::Record
        endpoint '{+datastore}/v2/favorites'
      end
    end

    it 'fails when trying to use an endpoint for validations that does not support it' do
      expect(lambda do
        Favorite.build.valid?
      end).to raise_error('Endpoint does not support validations!')
    end
  end

  context 'generate validation url from locally passed params' do
    before do
      class User < LHS::Record
        endpoint 'http://datastore/v2/users/{user_id}', validates: { params: { persist: false } }
      end
    end

    it 'takes local params when generating validation url' do
      stub_request(:post, "http://datastore/v2/users/2?persist=false")
        .to_return(status: 201)
      expect(
        user.valid?(params: { user_id: 2 })
      ).to eq true
    end
  end
end
