require 'rails_helper'

describe LHS::Record::Request do
  before(:each) do
    class Record < LHS::Record
      endpoint 'http://datastore/feedbacks/:id'
    end
  end

  context '#options_for_data' do
    it 'extract request options from raw data' do
      options = LHS::Record.send(:url_option_for, LHS::Data.new({ href: 'http://datastore/feedbacks/1' }, nil, Record))
      expect(options[:url]).to eq 'http://datastore/feedbacks/1'
    end

    it 'extract a list of request options from raw data if data is a collection' do
      options = LHS::Record.send(:url_option_for, LHS::Data.new({ items: [{ href: 'http://datastore/feedbacks/1' }] }, nil, Record))
      expect(options[0][:url]).to eq 'http://datastore/feedbacks/1'
    end

    it 'extract request options from raw nested data' do
      options = LHS::Record.send(:url_option_for, LHS::Data.new({ reviews: { href: 'http://datastore/reviews/1' } }, nil, Record), :reviews)
      expect(options[:url]).to eq 'http://datastore/reviews/1'
    end
  end
end
