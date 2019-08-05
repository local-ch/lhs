# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  before do
    class Record < LHS::Record
      endpoint 'http://datastore/records/'
      endpoint 'http://datastore/records/{id}'
    end
  end

  context 'href_for' do

    it 'injects variables and returns href' do
      expect(Record.href_for(1)).to eq 'http://datastore/records/1'
      expect(Record.href_for('vmasd241')).to eq 'http://datastore/records/vmasd241'
    end

    it 'also works with url_for (alias)' do
      expect(Record.url_for(1)).to eq 'http://datastore/records/1'
      expect(Record.url_for('vmasd241')).to eq 'http://datastore/records/vmasd241'
    end
  end
end
