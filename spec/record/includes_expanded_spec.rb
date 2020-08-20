# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'includes all (expanded)' do
    before do
      class Record < LHS::Record
        endpoint 'http://records/{id}'
      end

      stub_request(:get, "http://records/1")
        .to_return(
          body: {
            car: { href: 'http://records/1/car' }
          }.to_json
        )

      stub_request(:get, "http://records/1/car?color=blue&limit=100")
        .to_return(
          body: { href: 'http://records/cars/1' }.to_json
        )

      stub_request(:get, "http://records/cars/1?color=blue&limit=100")
        .to_return(
          body: { name: 'wrum wrum' }.to_json
        )
    end

    it 'expands linked resources and forwards proper reference' do
      record = Record.includes(:car).references(car: { params: { color: :blue } }).find(1)
      expect(
        record.car.name
      ).to eq 'wrum wrum'
    end  
  end
end
