require 'rails_helper'

describe LHS::Record do
  context 'inherit endpoints' do

    before(:each) do
      class Base < LHS::Record
        endpoint 'records/:id'
      end

      class Example < Base
      end
    end

    it 'inherits endpoints based on ruby class_attribute behaviour' do
      stub_request(:get, 'http://records/1').to_return(body: [].to_json)
      Example.find(1)
    end
  end
end
