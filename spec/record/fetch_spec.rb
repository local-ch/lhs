require 'rails_helper'

describe LHS::Record do
  before(:each) do
    class Record < LHS::Record
      endpoint 'http://datastore/records/'
    end
  end

  context 'fetch' do
    let!(:request_stub) do
      stub_request(:get, "http://datastore/records/?available=true&color=blue&range=%3E26")
        .to_return(body: [{
          name: 'Steve'
        }].to_json)
    end

    it 'resolves chains' do
      records = Record.where(color: 'blue').where(range: '>26', available: true).fetch
      expect(request_stub).to have_been_requested
      expect(records.first.name).to eq 'Steve'
    end
  end
end
