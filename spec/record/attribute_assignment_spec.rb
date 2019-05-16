# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  before do
    class LocalEntry < LHS::Record
      endpoint '{+datastore}/local-entries'
    end
  end

  context '#assign_attributes' do
    it 'sets the attributes' do
      entry = LocalEntry.new
      entry.assign_attributes(company_name: 'localsearch')
      expect(entry.company_name).to eq 'localsearch'
    end
  end

  context '#attributes=' do
    it 'sets the attributes' do
      entry = LocalEntry.new
      entry.attributes = { company_name: 'localsearch' }
      expect(entry.company_name).to eq 'localsearch'
    end
  end

  context 'when not a hash was passed' do
    it 'raises an error' do
      entry = LocalEntry.new
      expect do
        entry.assign_attributes([:company_name, 'localsearch'])
      end.to raise_error(ArgumentError)
    end
  end
end
