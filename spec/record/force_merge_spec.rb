# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'merge' do

    before do
      class Change < LHS::Record
        endpoint 'https://onboarding/places/{id}/change'
      end
    end

    it 'merges a given hash' do
      stub_request(:get, "https://onboarding/places/1/change")
        .to_return(body: { entry: { name: 'Steve', address: 'Zurich' }, products: ['LBP'] }.to_json)
      record = Change.find(1)
      record.merge!(entry: { name: 'Paul' })
      expect(record.entry.name).to eq 'Paul'
      expect(record.entry.address).to eq nil
      expect(record.products.to_a).to eq ['LBP']
    end

    it 'merges! a given hash' do
      stub_request(:get, "https://onboarding/places/1/change")
        .to_return(body: { entry: { name: 'Steve', address: 'Zurich' }, products: ['LBP'] }.to_json)
      record = Change.find(1)
      new_record = record.merge(entry: { name: 'Paul' })
      expect(new_record.entry.name).to eq 'Paul'
      expect(new_record.entry.address).to eq nil
      expect(new_record.products.to_a).to eq ['LBP']
      expect(record.entry.name).to eq 'Steve'
      expect(record.entry.address).to eq 'Zurich'
      expect(record.products.to_a).to eq ['LBP']
    end

    it 'deep_merge! a given hash' do
      stub_request(:get, "https://onboarding/places/1/change")
        .to_return(body: { entry: { name: 'Steve', address: 'Zurich' } }.to_json)
      record = Change.find(1)
      record.deep_merge!(entry: { name: 'Paul' })
      expect(record.entry.name).to eq 'Paul'
      expect(record.entry.address).to eq 'Zurich'
    end

    it 'deep_merge a given hash' do
      stub_request(:get, "https://onboarding/places/1/change")
        .to_return(body: { entry: { name: 'Steve', address: 'Zurich' } }.to_json)
      record = Change.find(1)
      new_record = record.deep_merge(entry: { name: 'Paul' })
      expect(new_record.entry.name).to eq 'Paul'
      expect(new_record.entry.address).to eq 'Zurich'
      expect(record.entry.name).to eq 'Steve'
    end
  end
end
