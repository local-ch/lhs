require 'rails_helper'

describe LHS::Item do

  before(:each) do
    class SomeService < LHS::Service
      endpoint ':datastore/v2/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    LHS::Data.new(json, nil, SomeService)
  end

  let(:item) do
    data[0]
  end

  context 'delegates methods to raw' do

    %w(present? blank? empty?).each do |method|
      it "delegates #{method} to raw" do
        expect(item.send(method.to_sym)).not_to be_nil
      end
    end
  end
end
