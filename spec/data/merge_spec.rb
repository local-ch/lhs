require 'rails_helper'

describe LHS::Data do
  before(:each) do
    class Record < LHS::Record
      endpoint ':datastore/v2/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end

  let(:data) do
    described_class.new({
                          href: 'http://www.local.ch/v2/stuff'
                        }, nil, Record)
  end

  let(:loaded_data) do
    described_class.new({
                          href: 'http://www.local.ch/v2/stuff',
                          id: '123123123'
                        }, nil, Record)
  end

  context 'merging' do
    it 'merges data' do
      data.merge_raw!(loaded_data)
      expect(data.id).to eq loaded_data.id
    end
  end
end
