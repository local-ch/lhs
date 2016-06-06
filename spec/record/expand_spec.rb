require 'rails_helper'

describe LHS::Record do
  context 'expand nested resources' do
    before(:each) do
      class Record < LHS::Record
        endpoint 'http://datastore/records'
        endpoint 'http://datastore/records/:id'
      end
    end

    it 'expands nested resources by passing parameters' do
      stub_request(:get, "http://datastore/records/1?expand=feedbacks")
        .to_return(body: {
          feedbacks: {
            href: "http://datastore/records/1/feedbacks",
            items: [{ review: 'This is great' }]
          }
        }.to_json)
      record = Record.includes(:feedbacks).find(1)
      expect(record.feedbacks.first.review).to eq 'This is great'
    end

    it 'falls back to expand links itself when expand was not providing data' do
      stub_request(:get, "http://datastore/records/1?expand=feedbacks")
        .to_return(body: {
          feedbacks: {
            href: "http://datastore/records/1/feedbacks"
          }
        }.to_json)
      feedbacks_request = stub_request(:get, "http://datastore/records/1/feedbacks")
        .to_return(body: {
          items: [{ review: 'This is great' }]
        }.to_json)
      record = Record.includes(:feedbacks).find(1)
      expect(record.feedbacks.first.review).to eq 'This is great'
      assert_requested feedbacks_request
    end

    it 'expands also more complex includes' do
      stub_request(:get, "http://datastore/records/1?expand=customer.addresses,categories")
        .to_return(body: {}.to_json)
      Record.includes([{ customer: :addresses }, :categories]).find(1)
    end

    it 'expands also realy complex includes' do
      stub_request(:get, "http://datastore/records/1?expand=customer.address,customer.categories.region,customer.categories.country.political_region")
        .to_return(body: {}.to_json)
      Record.includes(
        customer: [
          :address,
          {
            categories: [
              :region,
              {
                country: :political_region
              }
            ]
          }
        ]
      ).find(1)
    end

    it 'expands also realy complex alternative includes' do
      stub_request(:get, "http://datastore/records/1?expand=user.contracts.company.address,customer.address,customer.categories.region,customer.categories.country.political_region")
        .to_return(body: {}.to_json)
      Record.includes(
        user: [
          { contracts: { company: :address } }
        ],
        customer: [
          :address,
          {
            categories: [
              :region,
              {
                country: :political_region
              }
            ]
          }
        ]
      ).find(1)
    end
  end
end
