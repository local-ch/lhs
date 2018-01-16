require 'rails_helper'

describe LHS::Collection do
  let(:total) { 0 }

  let(:limit) { 50 }

  let(:offset) { 0 }

  let(:collection) do
    {
      href: "#{datastore}/feedbacks",
      items: [],
      total: total,
      limit: limit,
      offset: offset
    }
  end

  let(:item) do
    {
      href: "#{datastore}/users/1",
      feedbacks: collection
    }
  end

  let(:datastore) { 'http://local.ch/v2' }

  before(:each) do
    LHC.config.placeholder('datastore', datastore)
    class Feedback < LHS::Record
      endpoint '{+datastore}/feedbacks'
      endpoint '{+datastore}/feedbacks/{id}'
    end
    class User < LHS::Record
      endpoint '{+datastore}/users'
      endpoint '{+datastore}/users/{id}'
    end
  end

  it 'provides meta data for collections' do
    stub_request(:get, "#{datastore}/feedbacks").to_return(status: 200, body: collection.to_json)
    feedbacks = Feedback.where
    expect(feedbacks.total).to eq total
    expect(feedbacks.limit).to eq limit
    expect(feedbacks.offset).to eq offset
    expect(feedbacks.href).to eq "#{datastore}/feedbacks"
  end

  it 'provides meta data also when navigating' do
    stub_request(:get, "#{datastore}/users/1").to_return(status: 200, body: item.to_json)
    user = User.find(1)
    expect(user.feedbacks.href).to eq "#{datastore}/feedbacks"
  end
end
