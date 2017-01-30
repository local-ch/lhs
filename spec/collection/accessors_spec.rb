require 'rails_helper'

describe LHS::Collection do
  let(:datastore) { 'http://local.ch/v2' }
  let(:items) { [{name: 'Steve'}] }
  let(:extra) { 'extra' }
  let(:collection) { Record.where }

  context 'accessors' do
    let(:response_data) do
      {
        items: items,
        extra: extra,
        total: 1
      }
    end

    before(:each) do
      LHC.config.placeholder('datastore', datastore)
      class Record < LHS::Record
        endpoint ':datastore/records`'
      end
      stub_request(:get, %r{http://local.ch/v2/records})
        .to_return(body: response_data.to_json)
    end

    it 'allows access to extra data passed with collection' do
      expect(collection.extra).to eq(extra)
    end
  end
end
