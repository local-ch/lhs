require 'rails_helper'

describe LHS::Record do
  let(:datastore) { 'http://local.ch/v2' }

  before(:each) do
    LHC.config.placeholder(:datastore, datastore)
    class Record < LHS::Record
      endpoint ':datastore/content-ads/:campaign_id/feedbacks'
      endpoint ':datastore/content-ads/:campaign_id/feedbacks/:id'
      endpoint ':datastore/feedbacks'
      endpoint ':datastore/feedbacks/:id'
    end
  end

  context '#keys' do
    subject { Record.find('z12f-3asm3ngals') }
    let(:keys) do
      [:href, :campaign, :source_id, :recommended, :modified, :created_date, :comments]
    end

    before(:each) do
      stub_request(:get, "#{datastore}/feedbacks/z12f-3asm3ngals")
        .to_return(status: 200, body: load_json(:feedback))
    end

    it { should respond_to(:keys) }

    it 'returns an array of top-level keys' do
      expect(subject.keys).to be_kind_of Array
      expect(subject.keys).to eq keys
    end
  end
end
