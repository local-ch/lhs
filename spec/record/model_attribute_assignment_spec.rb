# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  before do
    class LocalEntry < LHS::Record
      endpoint '{+datastore}/local-entries'
    end
  end

  it 'sets the attributes' do
    entry = LocalEntry.new
    entry.assign_attributes(company_name: 'localsearch')
    expect(entry.company_name).to eq 'localsearch'
  end
end
