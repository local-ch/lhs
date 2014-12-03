require 'rails_helper'

describe LHS::Service do

  let(:datastore) { 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2' }
  before { LHC.config.placeholder(:datastore, datastore) }
  before(:each) do
    class CorrectService < LHS::Service
      endpoint ':datastore/feedbacks'
    end

    class WrongService < LHS::Service
      endpoint ':datastore/feedbacks/wrong'
    end
  end

  context 'first' do

    it 'finds a single record' do
      stub_request(:get, "#{datastore}/feedbacks?limit=1").
      to_return(status: 200, body: load_json(:feedback))

      CorrectService.first.source_id
    end

    it 'returns nil if no record was found' do
      stub_request(:get, "#{datastore}/feedbacks/wrong?limit=1").
      to_return(status: 404)
      expect(WrongService.first).to be_nil
    end
  end
end
