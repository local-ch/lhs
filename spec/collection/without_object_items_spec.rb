require 'rails_helper'

describe LHS::Collection do
  let(:datastore) { 'http://local.ch/v2' }

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Account < LHS::Record
      endpoint '{+datastore}/accounts/{id}'
    end
  end

  let(:data) {
    {
      'authorities' => ['ROLE_USER', 'ROLE_LOCALCH_ACCOUNT']
    }
  }

  it 'lets you access items of an array if they are not objects' do
    stub_request(:get, "#{datastore}/accounts/1").to_return(status: 200, body: data.to_json)
    feedback = Account.find(1)
    expect(feedback.authorities.first).to eq 'ROLE_USER'
    expect(feedback.authorities[1]).to eq 'ROLE_LOCALCH_ACCOUNT'
  end
end
