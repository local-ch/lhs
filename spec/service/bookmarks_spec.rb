require 'rails_helper'

describe LHS::Service do

    let(:datastore) { 'http://silo2:8082' }
  before(:each) { LHC.config.placeholder('datastore', datastore) }

  context 'bookmarks' do
    before(:each) do
      class TermsAndConditions < LHS::Service
        endpoint ':datastore/v2/agbs/active'
      end
    end

    it 'returns the active AGB' do
      stub_request(:get, "#{datastore}/v2/agbs/active/").to_return(
        status: 200,
        body: { 'abc' => 1 }.to_json
      )

      expect(TermsAndConditions.where(:active).abc).to be == 1
    end

    # it 'returns the inactive AGBs with a create_date before "2014-01-01"' do
    #   stub_request(:get, "#{datastore}/agbs/inactive?after=2014-01-01").to_return(
    #     status: 200,
    #     body: { 'test' => 2 }.to_json
    #   )
    #
    #   expect(TermsAndConditions.where('abc', {test: 1}, :inactive, :test, id: 1, after: '2014-01-01').test).to be == 2
    # end

  end
end
