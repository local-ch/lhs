require 'rails_helper'

describe LHS::Service do

  context 'create' do

    let(:datastore) { 'http://local.ch/v2' }

    before(:each) do
      LHC.config.placeholder('datastore', datastore)
      class Feedback < LHS::Service
        endpoint ':datastore/content-ads/:campaign_id/feedbacks'
        endpoint ':datastore/feedbacks'
      end
    end

    let(:object) do
      {
        recommended: true,
        source_id: 'aaa'
      }
    end

    it 'creates new record on the backend' do
      stub_request(:post, "#{datastore}/feedbacks")
      .with(body: object.to_json)
      .to_return(status: 200, body: object.to_json)
      record = Feedback.create(object)
      expect(record.recommended).to eq true
      expect(record.errors).to eq nil
    end

    it 'uses proper endpoint when creating data' do
      stub_request(:post, "#{datastore}/content-ads/12345/feedbacks")
      .with(body: object.to_json)
      .to_return(status: 200, body: object.to_json)
      Feedback.create(object.merge(campaign_id: '12345'))
    end

    it 'merges backend response object with object' do
      body = object.merge(additional_key: 1)
      stub_request(:post, "#{datastore}/content-ads/12345/feedbacks")
      .with(body: object.to_json)
      .to_return(status: 200, body: body.to_json)
      data = Feedback.create(object.merge(campaign_id: '12345'))
      expect(data.additional_key).to eq 1
    end

    context 'creation errors' do
      let(:creation_error) do
        {
          "status" => 400,
          "fields" => [
            {
              "name" => "ratings",
              "details" => [{ "code" => "REQUIRED_PROPERTY_VALUE" }]
              },{
              "name" => "recommended",
              "details" => [{"code" => "REQUIRED_PROPERTY_VALUE"}]
            }
          ]
        }
      end

      it 'provides errors accessor on the record when creation failed using create' do
        stub_request(:post, "#{datastore}/content-ads/12345/feedbacks")
        .to_return(status: 400, body: creation_error.to_json)
        feedback = Feedback.create(object.merge(campaign_id: '12345'))
        expect(feedback.errors).to be_kind_of LHS::Errors
      end

      it 'raises an exception when creation failed using create!' do
        stub_request(:post, "#{datastore}/content-ads/12345/feedbacks")
        .to_return(status: 400, body: creation_error.to_json)
        expect(->{
          Feedback.create!(object.merge(campaign_id: '12345'))
        }).to raise_error
      end
    end
  end
end
