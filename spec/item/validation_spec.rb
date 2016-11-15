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
      expect(-> {
        class User < LHS::Record
          endpoint 'http://datastore/v2/users', validates: true
        end
      }).to raise_error 'Validates with either true or a simple string is deprecated: https://github.com/local-ch/lhs#validation'
      expect(-> {
        class Record < LHS::Record
          endpoint 'http://datastore/v2/records', validates: 'publish'
        end
      }).to raise_error 'Validates with either true or a simple string is deprecated: https://github.com/local-ch/lhs#validation'
    end
  end

  context 'passing validation parameters' do
    let(:user) do
      User.build(email: 'steve@local.ch')
    end

    it 'validates {publish: false}' do
      class User < LHS::Record
        endpoint 'http://datastore/v2/users', validates: { publish: false }
      end
      stub_request(:post, "http://datastore/v2/users?publish=false").to_return(body: {}.to_json)
      expect(user.valid?).to eq true
    end

    it 'validates {persist: false}' do
      class User < LHS::Record
        endpoint 'http://datastore/v2/users', validates: { persist: false }
      end
      stub_request(:post, "http://datastore/v2/users?persist=false").to_return(body: {}.to_json)
      expect(user.valid?).to eq true
    end

    it 'validates {validates: true}' do
      class User < LHS::Record
        endpoint 'http://datastore/v2/users', validates: { validates: true }
      end
      stub_request(:post, "http://datastore/v2/users?validates=true").to_return(body: {}.to_json)
      expect(user.valid?).to eq true
    end

    it 'validates /validate' do
      class User < LHS::Record
        endpoint 'http://datastore/v2/users', validates: '/validate'
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

    before(:each) do
      class User < LHS::Record
        endpoint 'http://datastore/v2/users', validates: { persist: false }
      end
    end

    it 'provides validation errors through the error object' do
      successful_validation
      expect(user.valid?).to eq true
      user.email = 'not a valid email'
      failing_validation
      expect(user.valid?).to eq false
      expect(user.errors[:email]).to be
    end

    it 'gets reset when revalidation' do
      failing_validation
      expect(user.valid?).to eq false
      user.email = 'steve@local.ch'
      successful_validation
      expect(user.valid?).to eq true
      expect(user.errors).to be_nil
    end
  end

  context 'endpoint does not support validations' do
    before(:each) do
      class Favorite < LHS::Record
        endpoint ':datastore/v2/favorites'
      end
    end

    it 'fails when trying to use an endpoint for validations that does not support it' do
      expect(lambda do
        Favorite.build.valid?
      end).to raise_error('Endpoint does not support validations!')
    end
  end
end
