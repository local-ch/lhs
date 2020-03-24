# frozen_string_literal: true

require "rails_helper"

describe LHS, type: :request do
  context 'autoloading' do

    let(:endpoints) { LHS::Record::Endpoints.all }

    it "pre/re-loads all LHS classes initialy, because it's necessary for endpoint-to-record-class-discovery", reset_before: false do

      expect(endpoints['http://datastore/v2/users']).to be_present
      expect(endpoints['http://datastore/v2/users/{id}']).to be_present

      expect(
        DummyUser.endpoints.detect { |endpoint| endpoint.url == 'http://datastore/v2/users' }
      ).to be_present
      expect(
        DummyUser.endpoints.detect { |endpoint| endpoint.url == 'http://datastore/v2/users/{id}' }
      ).to be_present
    end

    it "also pre/re-loads all LHS classes that inherited from an LHS provider, because it's necessary for endpoint-to-record-class-discovery", reset_before: false do

      expect(endpoints['http://customers']).to be_present
      expect(endpoints['http://customers/{id}']).to be_present

      expect(
        DummyCustomer.endpoints.detect { |endpoint| endpoint.url == 'http://customers' }
      ).to be_present
      expect(
        DummyCustomer.endpoints.detect { |endpoint| endpoint.url == 'http://customers/{id}' }
      ).to be_present

      customer_request = stub_request(:get, "http://customers/1")
        .with(
          headers: {
            'Authorization' => 'token123'
          }
        )
        .to_return(body: { name: 'Steve' }.to_json)

      DummyCustomer.find(1)

      expect(customer_request).to have_been_requested
    end
  end
end
