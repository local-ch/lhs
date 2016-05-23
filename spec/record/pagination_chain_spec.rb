require 'rails_helper'

describe LHS::Record do

  context 'pagination chain' do

    before(:each) do
      class Record < LHS::Record
        endpoint 'http://local.ch/records'
        endpoint 'http://local.ch/records/:id'
      end
    end

    it 'allows to chain pagination methods' do
      stub_request(:get, "http://local.ch/records?color=blue&offset=300&limit=100").to_return(body: [].to_json)
      Record.where(color: 'blue').page(3).first
      stub_request(:get, "http://local.ch/records?color=blue&offset=30&limit=10").to_return(body: [].to_json)
      Record.where(color: 'blue').page(3).limit(10).first
      Record.where(color: 'blue').limit(10).page(3).first
    end
  end
end
