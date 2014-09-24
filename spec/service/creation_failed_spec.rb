require 'rails_helper'

describe LHS::Service do

  context 'creation failed' do

    before(:each) do
      class SomeService < LHS::Service
        endpoint ':datastore/v2/:campaign_id/feedbacks'
        endpoint ':datastore/v2/feedbacks'
      end
    end

    let(:creation_error) do
      {
        "status" => 400,
        "message" => "ratings must be set when review or name or review_title is set | The property value is required; it cannot be null, empty, or blank.",
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

    it 'provides errors when creation failed' do
      stub_request(:post, "http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks")
      .to_return(status: 400, body: creation_error.to_json)
      record = SomeService.create({})
      expect(record.errors).to be
      expect(record.errors.include?(:ratings)).to eq true
      expect(record.errors.include?(:recommended)).to eq true
      expect(record.errors[:ratings]).to eq ['REQUIRED_PROPERTY_VALUE']
      expect(record.errors[:recommended]).to eq ['REQUIRED_PROPERTY_VALUE']
    end
  end
end
