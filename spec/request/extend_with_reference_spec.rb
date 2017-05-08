require 'rails_helper'

describe LHS::Record::Request do
  
  before(:each) do
    class Record < LHS::Record
      endpoint 'http://datastore/feedbacks/:id'
    end
  end

  context '#extend_with_reference' do
    
    it 'extends given options with the one for the refernce' do
      options = LHS::Record.send(:extend_with_reference, { url: 'http://datastore/feedbacks/1' }, { auth: { bearer: '123' }})
      expect(options[:auth][:bearer]).to eq '123'
    end

    it 'extends given list of options with the one for the refernce' do
      options = LHS::Record.send(:extend_with_reference, [{ url: 'http://datastore/feedbacks/1' }], { auth: { bearer: '123' }})
      expect(options[0][:auth][:bearer]).to eq '123'
    end
  end
end
