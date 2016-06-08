require 'rails_helper'

describe LHS::Item do
  let(:datastore) { 'http://local.ch' }

  let(:validation_parameter) { 'persist' }

  let(:mock_validation) do
    successful_validation
  end

  let(:successful_validation) do
    stub_request(:post, "#{datastore}/v2/users?#{validation_parameter}=false").to_return(body: '{}')
  end

  before(:each) do
    mock_validation
  end

  context 'custom validation parameter' do
    let(:validation_parameter) { 'publish' }

    let(:user) do
      User.build(email: 'steve@local.ch')
    end

    before(:each) do
      LHC.config.placeholder('datastore', datastore)
      class User < LHS::Record
        endpoint ':datastore/v2/users', validates: 'publish'
      end
    end

    it 'validates' do
      expect(user.valid?).to eq true
    end
  end

  context 'default parameter' do
    before(:each) do
      LHC.config.placeholder('datastore', datastore)
      class User < LHS::Record
        endpoint ':datastore/v2/users', validates: true
      end
    end

    let(:failing_validation) do
      stub_request(:post, "#{datastore}/v2/users?persist=false")
        .to_return(status: 400,
                   body: {
                     field_errors: [{ code: "UNSUPPORTED_PROPERTY_VALUE", "path" => ["email"] }]
                   }.to_json
                  )
    end

    context 'valid data' do
      let(:user) do
        User.build(email: 'steve@local.ch')
      end

      it 'validates' do
        expect(user.valid?).to eq true
      end

      it 'turns to be invalid if validating on changed, invalid data' do
        expect(user.valid?).to eq true
        user.email = 'not a valid email'
        failing_validation
        expect(user.valid?).to eq false
        expect(user.errors[:email]).to be
      end
    end

    context 'invalid data' do
      let(:user) do
        User.build(email: 'im not an email address')
      end

      let(:mock_validation) do
        failing_validation
      end

      it 'does not validate and provides error messages' do
        expect(user.valid?).to eq false
        expect(user.errors[:email]).to be
      end

      it 'resets errors when revalidating' do
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

  context 'pick right endpoint' do

    before(:each) do
      class Record < LHS::Record
        endpoint 'http://datastore/v2/records'
        endpoint 'http://datastore/v2/records/:id', validates: true
      end
      stub_request(:get, "http://datastore/v2/records/1")
        .to_return(body: { href: 'http://datastore/v2/records/1' }.to_json)
       stub_request(:post, "http://datastore/v2/records/1?persist=false")
        .to_return(body: {}.to_json)
    end

    it 'takes the right endpoint for validation' do
      record = Record.find(1)
      record.valid?
    end
  end
end
