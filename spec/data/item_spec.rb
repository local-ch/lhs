require 'rails_helper'

describe LHS::Data do
  before(:each) do
    class Record < LHS::Record
      endpoint ':datastore/v2/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
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

  context 'item' do
    it 'makes data accessible' do
      expect(item.href).to be_kind_of String
      expect(item.recommended).to be_kind_of TrueClass
      expect(item.average_rating).to be_kind_of Float
    end

    it 'returns nil if no data is present' do
      expect(item.something).to eq nil
    end

    it 'returns TimeWithZone if string can be parsed as date_time' do
      expect(item.created_date).to be_kind_of ActiveSupport::TimeWithZone
    end

    it 'returns date if string can be parsed as date' do
      expect(item.valid_from).to be_kind_of Date
    end
  end

  context 'different date time formats' do
    let(:item) do
      item = data[0]
      item._raw[:created_date] = '2016-07-09T13:45:00+00:00'
      item
    end

    it 'returns TimeWithZone if string can be parsed as date_time' do
      expect(item.created_date).to be_kind_of ActiveSupport::TimeWithZone
    end
  end
end
