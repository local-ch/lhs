require 'rails_helper'

describe LHS::Data do
  before(:each) do
    class Record < LHS::Record
      endpoint ':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks'
      endpoint ':datastore/v2/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end

  context 'root' do
    it 'is navigateable from nested data' do
      root = described_class.new({ 'items' => [{ 'campaign' => { 'id' => 123 } }] }, nil, Record)
      child = root.first
      leafe = child.campaign
      expect(leafe._root).to eq root
      expect(leafe._parent).to be_kind_of described_class
      expect(leafe._parent._parent).to be_kind_of described_class
      expect(leafe._parent._parent).to eq root
    end
  end
end
