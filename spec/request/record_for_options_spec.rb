require 'rails_helper'

describe LHS::Record::Request do
  before(:each) do
    class Record < LHS::Record
      endpoint 'http://datastore/feedbacks/:id'
    end
  end

  context '#record_for_options' do
    it 'identifies lhs record from given options, as all request have to be done through LHS Records' do
      record = LHS::Record.send(:record_for_options, url: 'http://datastore/feedbacks/1')
      expect(record).to eq Record
    end
  end
end
