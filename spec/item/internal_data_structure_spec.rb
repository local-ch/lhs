require 'rails_helper'

describe LHS::Item do

  before(:each) do
    class Feedback < LHS::Record
      endpoint ':datastore/v2/feedbacks'
      endpoint ':datastore/v2/feedbacks/:id'
    end
  end

  let(:hash) do
    {'addresses' => [{'businesses' => {'identities' => [{'name' => 'Löwenzorn'}]}}]}
  end

  let(:data) do
    LHS::Data.new(hash, nil, Feedback)
  end

  it 'deep symbolizes keys internaly when new data is initalized' do
    expect(data._raw[:addresses].first[:businesses][:identities].first[:name]).to eq 'Löwenzorn'
    data.id = 'YZ12'
    expect(data._raw.keys).to include(:id)
  end

  it 'deep symbolizes internal data' do
    feedback = Feedback.build(hash)
    expect(feedback._raw.keys).to include(:addresses)
    expect(feedback._raw[:addresses].first[:businesses][:identities].first[:name]).to eq 'Löwenzorn'
  end

  it 'deep symbolizes internal data when building new objects' do
    feedback = Feedback.build('name' => 'BB8')
    expect(feedback._data._raw.keys).to include(:name)
  end 

  it 'can handle ActionController::Parameters' do
    params = ActionController::Parameters.new('name' => 'Han')
    feedback = Feedback.build(params)
    expect(feedback._data._raw.keys).to include(:name)
  end
end
