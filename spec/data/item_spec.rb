# frozen_string_literal: true

require 'rails_helper'

describe LHS::Data do
  before do
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
    context 'with numbered time zone' do
      let(:item) do
        item = data[0]
        item._raw[:created_date] = '2016-07-09T13:45:00+02:00'
        item
      end

      it 'returns TimeWithZone if string can be parsed as date_time' do
        expect(item.created_date).to be_kind_of ActiveSupport::TimeWithZone
      end

      it 'has UTC time zone' do
        expect(item.created_date.zone).to eq('UTC')
      end

      it 'has the right time' do
        expect(item.created_date.hour).to eq(11)
      end
    end

    context 'with lettered time zone' do
      let(:item) do
        item = data[0]
        item._raw[:created_date] = '2016-07-09T13:45:00Z'
        item
      end

      it 'returns TimeWithZone if string can be parsed as date_time' do
        expect(item.created_date).to be_kind_of ActiveSupport::TimeWithZone
      end

      it 'has UTC time zone' do
        expect(item.created_date.zone).to eq('UTC')
      end

      it 'has the right time' do
        expect(item.created_date.hour).to eq(13)
      end
    end

    context 'without seconds' do
      let(:item) do
        item = data[0]
        item._raw[:created_date] = '2016-07-09T13:45Z'
        item
      end

      it 'returns TimeWithZone if string can be parsed as date_time' do
        expect(item.created_date).to be_kind_of ActiveSupport::TimeWithZone
      end

      it 'has UTC time zone' do
        expect(item.created_date.zone).to eq('UTC')
      end

      it 'has the right time' do
        expect(item.created_date.hour).to eq(13)
      end
    end
  end

  context 'with attribute called attributes' do
    let(:attributes) do
      {
        de: 'Bezahlung mit EC-Karte',
        en: 'Accepts EC-Card',
        fr: 'Paiement par carte EC',
        it: 'Pagamento con carta EC'
      }
    end

    let(:json) do
      {
        href: 'http://test.ch/place-attributes?&offset=0&limit=10',
        items: [
          {
              attributes: attributes,
              tag: 'accept_dd',
              href: 'http://test.ch/place-attributes/accept_dd'
          }
        ],
        total: 1,
        offset: 0,
        limit: 10
      }.to_json
    end

    it 'is possible to return the attributes' do
      #expect(item.as_json).to eq(json)
      expect(item.attributes).to eq(attributes)
    end
  end
end
