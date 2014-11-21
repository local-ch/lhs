require 'rails_helper'

describe LHS::Data do

  before(:each) do
    class SomeService < LHS::Service
      endpoint ':datastore/v2/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end

  let(:data) do
    LHS::Data.new({
      href: 'http://www.local.ch/v2/stuff'
    }, nil, SomeService)
  end

  let(:loaded_data) do
    LHS::Data.new({
      href: 'http://www.local.ch/v2/stuff',
      id: '123123123'
    }, nil, SomeService)
  end

  context 'merging' do

    it 'merges data' do
      data.merge!(loaded_data)
      expect(data.id).to eq loaded_data.id
    end
  end
end
