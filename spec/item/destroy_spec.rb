# frozen_string_literal: true

require 'rails_helper'

describe LHS::Item do
  before do
    LHC.config.placeholder('datastore', datastore)
    class Record < LHS::Record
      endpoint '{+datastore}/v2/{campaign_id}/feedbacks'
      endpoint '{+datastore}/v2/feedbacks'
    end
  end

  let(:datastore) do
    'http://local.ch'
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

  context 'destroy' do
    it 'destroys the item on the backend' do
      stub_request(:delete, "#{datastore}/v2/feedbacks/0sdaetZ-OWVg4oBiBJ-7IQ")
        .to_return(status: 200)
      expect(item.destroy._raw).to eq item._raw
    end

    it 'updates the request information on the item' do
      no_content = 204
      stub_request(:delete, "#{datastore}/v2/feedbacks/0sdaetZ-OWVg4oBiBJ-7IQ")
        .to_return(status: no_content)
      expect(item.destroy._request.response.code).to eq no_content
    end

    context 'includes and empty response' do
      before do
        class AnotherRecord < LHS::Record
          endpoint '{+datastore}/v2/:campaign_id/restaurants'
        end
      end

      it 'destroys an item even though it includes additonal services and an empty response body' do
        stub_request(:delete, "#{datastore}/v2/feedbacks/1")
          .to_return(status: 204, body: '')
        data = { href: "#{datastore}/v2/feedbacks/1", restaurant: { href: "#{datastore}/v2/restaurants/1" } }
        stub_request(:get, "#{datastore}/v2/feedbacks?id=1")
          .to_return(status: 200, body: data.to_json)
        stub_request(:get, "#{datastore}/v2/restaurants/1")
          .to_return(status: 200, body: { name: 'Casa Ferlin' }.to_json)
        item = Record.includes(:restaurant).find(1)
        item.destroy
      end
    end

    context 'when item does not have any href' do
      let(:business_data) do
        {
          id: '12345',
          name: 'localsearch'
        }
      end

      let(:business_collection) do
        [business_data]
      end

      before do
        class Business < LHS::Record
          endpoint 'https://uberall/businesses'
          endpoint 'https://uberall/businesses/{id}'
        end

        stub_request(:get, "https://uberall/businesses")
          .to_return(body: business_collection.to_json)

        stub_request(:delete, "https://uberall/businesses/12345")
          .to_return(body: {
            status: 'SUCCESS',
            response: {
              success: true
            }
          }.to_json)
      end

      it "destroys the item using it's own id (data)" do
        business = Business.fetch.first
        expect(business.destroy._raw).to eq business_data
      end

      context 'item does not have an id' do
        let(:business_data) do
          {
            name: 'localsearch'
          }
        end

        it 'destroy the item using the id passed as options' do
          business = Business.fetch.first
          expect(business.destroy(params: { id: '12345' })._raw).to eq business_data
        end
      end
    end
  end
end
