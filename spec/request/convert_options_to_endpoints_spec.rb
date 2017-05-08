require 'rails_helper'

describe LHS::Record::Request do
  
  before(:each) do
    class Record < LHS::Record
      endpoint 'http://datastore/feedbacks/:id', params: { tracking: 123 }
    end
  end

  context '#convert_options_to_endpoint' do
    
    it 'identifies endpoint by given url and merges back endpoint template parameters' do
      options = LHS::Record.send(:convert_options_to_endpoints, { url: 'http://datastore/feedbacks/1' })
      expect(options[:params][:id]).to eq '1'
      expect(options[:url]).to eq 'http://datastore/feedbacks/:id'
    end

    it 'identifies endpoint by given url and merges back endpoint template parameters into an array, if array was given' do
      options = LHS::Record.send(:convert_options_to_endpoints, [{ url: 'http://datastore/feedbacks/1' }])
      expect(options[0][:params][:id]).to eq '1'
      expect(options[0][:url]).to eq 'http://datastore/feedbacks/:id'
    end

    it 'returnes nil if endpoint was not found for the given url' do
      options = LHS::Record.send(:convert_options_to_endpoints, { url: 'http://datastore/reviews/1' })
      expect(options).to eq nil
    end
  end
end
