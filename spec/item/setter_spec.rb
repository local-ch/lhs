require 'rails_helper'

describe LHS::Item do
  before(:each) do
    class Record < LHS::Record
      endpoint '{+datastore}/v2/{campaign_id}/feedbacks'
      endpoint '{+datastore}/v2/feedbacks'
    end
  end

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    LHS::Data.new(json, nil, Record)
  end

  let(:item) do
    data[0]
  end

  context 'item setter' do
    it 'sets the value for an existing attribute' do
      expect((item.name = 'Steve')).to eq 'Steve'
      expect(item.name).to eq 'Steve'
      expect(item._raw[:name]).to eq 'Steve'
    end

    it 'sets things to nil' do
      item.name = 'Steve'
      expect((item.name = nil)).to eq nil
      expect(item.name).to eq nil
    end

    it 'sets things to false' do
      item.recommended = true
      expect((item.recommended = false)).to eq false
      expect(item.recommended).to eq false
    end
  end
end
