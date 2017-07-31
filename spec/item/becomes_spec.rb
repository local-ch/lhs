require 'rails_helper'

describe LHS::Item do
  before(:each) do
    class Location < LHS::Record
      endpoint 'http://sync/locations'
      endpoint 'http://sync/locations/:id'
    end

    class Synchronization < LHS::Record
      endpoint 'http://sync/locations/:id/sync'
    end

    stub_request(:get, "http://sync/locations/1")
      .to_return(body: {
        id: 1,
        name: 'localsearch'
      }.to_json)

    stub_request(:post, "http://sync/locations/1/sync")
      .with(body: {
        name: 'localsearch'
      }.to_json)
      .to_return(status: 201)
  end

  context 'convert records from class A to class B' do
    it "becomes a record of another class" do
      location = Location.find(1)
      synchronization = location.becomes(Synchronization)
      expect(synchronization).to be_kind_of(Synchronization)
      synchronization.save!
      expect(synchronization).to be_kind_of(Synchronization)
    end
  end
end
