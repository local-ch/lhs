require 'rails_helper'

describe LHS::Item do
  before(:each) do
    class Record < LHS::Record
      endpoint ':datastore/v2/:campaign_id/feedbacks'
      endpoint ':datastore/v2/feedbacks'
    end
  end

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    LHS::Data.new(json, nil, Record)
  end

  let(:item) do
    data[0]
  end

  context 'save' do
    it 'persists changes on the backend' do
      stub_request(:post, item.href).with(body: item._raw.merge(name: 'Steve').to_json)
      item.name = 'Steve'
      expect(item.save).to eq true
    end

    it 'returns false if persting goes wrong' do
      stub_request(:post, item.href)
        .with(body: item._raw.to_json)
        .to_return(status: 500)
      expect(item.save).to eq false
    end

    it 'merges reponse data with object' do
      stub_request(:post, item.href)
        .with(body: item._raw.to_json)
        .to_return(status: 200, body: item._raw.merge(name: 'Steve').to_json)
      item.save
      expect(item.name).to eq 'Steve'
    end
  end

  context 'save!' do
    it 'raises if something goes wrong' do
      stub_request(:post, item.href)
        .with(body: item._raw.to_json)
        .to_return(status: 500)
      expect(-> { item.save! }).to raise_error LHC::ServerError
    end

    context 'without href' do
      before do
        LHC.config.placeholder('datastore', datastore)
        class Feedback < LHS::Record
          endpoint ':datastore/content-ads/:campaign_id/feedbacks'
        end
      end

      let(:datastore) { 'http://local.ch/v2' }
      let(:campaign_id) { 12345 }
      let(:object) { { recommended: true } }
      let(:item) { Feedback.new(object.merge(campaign_id: campaign_id)) }

      it 'removes params used to compute url from send data' do
        datastore_request = stub_request(:post, "#{datastore}/content-ads/#{campaign_id}/feedbacks")
          .with(body: object.to_json)
          .to_return(status: 200, body: object.to_json)

        item.save!
        expect(datastore_request).to have_been_made.once
      end
    end
  end
end
