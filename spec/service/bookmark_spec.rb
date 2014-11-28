require 'rails_helper'

describe LHS::Service do

  let(:datastore) { 'http://silo2:8082' }
  before(:each) { LHC.config.placeholder('datastore', datastore) }

  context 'bookmark' do
    before(:each) do
      class TermsAndConditions < LHS::Service
        endpoint ':datastore/v2/agbs'
      end
    end

    it 'returns the active AGB' do
      stub_request(:get, "#{datastore}/v2/agbs/active").to_return(
        status: 200,
        body: { 'dummy' => 'dummy' }.to_json
      )

      expect(TermsAndConditions.where(:active).dummy).to be == 'dummy'
    end

    it 'returns the inactive AGBs with a create_date before "2014-01-01"' do
      stub_request(:get, "#{datastore}/v2/agbs/inactive?after=2014-01-01").to_return(
        status: 200,
        body: { 'dummy' => 'dummy' }.to_json
      )

      expect(TermsAndConditions.where(:inactive, after: '2014-01-01').dummy).to be == 'dummy'
    end

  end
end
