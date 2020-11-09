# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do

  context 'merge request options ' do
    before do
      class Record < LHS::Record
        endpoint 'http://records/{id}'
      end

      stub_request(:get, 'http://records/1')
        .to_return(body: {
          place_attributes: [
            { href: 'https://attributes/bar' },
            { href: 'https://attributes/restaurant' },
            { href: 'https://attributes/cafe' }
          ]
        }.to_json)

      stub_request(:get, "https://attributes/restaurant?limit=100")
        .to_return(body: {}.to_json)
      stub_request(:get, "https://attributes/restaurant")
        .to_return(body: {}.to_json)
      stub_request(:get, "https://attributes/bar?limit=100")
        .to_return(body: {
          group: {
            href: 'https://group/general'
          }
        }.to_json)
      stub_request(:get, "https://attributes/cafe?limit=100")
        .to_return(body: {
          group: {
            href: 'https://group/general'
          }
        }.to_json)
      stub_request(:get, "https://group/general?limit=100&status=active")
        .to_return(body: {
          name: 'General'
        }.to_json)
    end

    context 'missing referenced options due to none existance of include' do

      it 'does not raise when trying to merge options with the options block' do
        LHS.options(throttle: { break: '80%' }) do
          record = Record
            .references(place_attributes: { group: { params: { status: 'active' } } })
            .includes([{ place_attributes: :group }])
            .find(1)
          expect(record.place_attributes[0].group.name).to eq 'General'
          expect(record.place_attributes[1].group).to eq nil
          expect(record.place_attributes[2].group.name).to eq 'General'
        end
      end
    end
  end
end
