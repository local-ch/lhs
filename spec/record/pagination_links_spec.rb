require 'rails_helper'

describe LHS::Record do
  context 'pagination links' do
    before(:each) do
      class Customer < LHS::Record
        endpoint 'http://datastore/customer'
      end
    end

    let!(:request) do
      stub_request(:get, "http://datastore/customer#{query}")
        .to_return(body: body)
    end

    let(:query) { "?name=#{name}&page=#{page}" }

    let(:customers) do
      Customer.where(name: name, page: page)
    end

    context 'next link is present, previous is not' do
      let(:name) { 'Simpl' }
      let(:page) { 2 }
      let(:body) do
        {
          next: "http://datastore/customer?name=#{name}&page=3",
          previous: "http://datastore/customer?name=#{name}&page=1",
          items: [{ name: 'Simplificator' }]
        }.to_json
      end

      it 'tells me that there is a next link' do
        expect(customers.next?).to eq true
        expect(customers.previous?).to eq true
      end
    end

    context 'no next link and no previous link is present' do
      let(:name) { 'Simplificator' }
      let(:page) { 1 }
      let(:body) do
        {
          items: [{ name: 'Simplificator' }]
        }.to_json
      end

      it 'tells me that there is no next link' do
        expect(customers.next?).to eq false
        expect(customers.previous?).to eq false
      end
    end
  end
end
