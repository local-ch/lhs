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

    context 'calls the correct stub' do
      it 'works without params' do
        stub_request(:get, "#{datastore}/v2/agbs/active")
        TermsAndConditions.where(:active)
      end

      it 'works with parameters' do
        stub_request(:get, "#{datastore}/v2/agbs/inactive?after=2014-01-01")
        TermsAndConditions.where(:inactive, after: '2014-01-01')
      end
    end
  end
end