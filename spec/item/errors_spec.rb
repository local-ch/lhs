require 'rails_helper'

describe LHS::Item do

  let(:datastore) { 'http://local.ch/v2' }

  let(:error_format_fields) do
      {
        "status" => 400,
        "message" => "ratings must be set when review or name or review_title is set | The property value is required; it cannot be null, empty, or blank.",
        "fields" => [
          {
            "name" => "ratings",
            "details" => [{ "code" => "REQUIRED_PROPERTY_VALUE" }, { "code" => "UNSUPPORTED_PROPERTY_VALUE" }]
          },{
            "name" => "recommended",
            "details" => [{"code" => "REQUIRED_PROPERTY_VALUE"}]
          }
        ]
      }
    end

  let(:error_format_field_errors) do
    {
      "status" => 400,
      "message" => "Some data in the request body failed validation. Inspect the field errors for details.",
      "field_errors" => [ {
        "code" => "UNSUPPORTED_PROPERTY_VALUE",
        "path" => [ "gender" ],
        "message" => "The property value is unsupported. Supported values are: FEMALE, MALE"
      }, {
        "code" => "INCOMPLETE_PROPERTY_VALUE",
        "path" => [ "gender" ],
        "message" => "The property value is incomplete. It misses some data"
      }, {
        "code" => "INCOMPLETE_PROPERTY_VALUE",
        "path" => [ "contract", "entry_id" ],
        "message" => "The property value is incomplete. It misses some data"
      }  ]
    }
  end 

  before(:each) do
    LHC.config.placeholder(:datastore, datastore)
    class SomeService < LHS::Service
      endpoint ':datastore/:campaign_id/feedbacks'
      endpoint ':datastore/feedbacks'
    end
  end

  context 'save failed' do

    it 'parses fields correctly when creation failed' do
      stub_request(:post, "#{datastore}/feedbacks")
        .to_return(status: 400, body: error_format_fields.to_json)
      record = SomeService.build
      record.name = 'Steve'
      result = record.save
      expect(result).to eq false
      expect(record.errors).to be
      expect(record.name).to eq 'Steve'
      expect(record.errors.include?(:ratings)).to eq true
      expect(record.errors.include?(:recommended)).to eq true
      expect(record.errors[:ratings]).to eq ['REQUIRED_PROPERTY_VALUE', 'UNSUPPORTED_PROPERTY_VALUE']
      expect(record.errors[:recommended]).to eq ['REQUIRED_PROPERTY_VALUE']
    end

    it 'parses field errors correctly when creation failed' do
      stub_request(:post, "#{datastore}/feedbacks")
        .to_return(status: 400, body: error_format_field_errors.to_json)
      record = SomeService.build
      record.name = 'Steve'
      result = record.save
      expect(result).to eq false
      expect(record.errors).to be
      expect(record.errors.include?(:gender)).to eq true
      expect(record.errors.include?(:"contract.entry_id")).to eq true
      expect(record.errors[:gender]).to eq ['UNSUPPORTED_PROPERTY_VALUE', 'INCOMPLETE_PROPERTY_VALUE']
      expect(record.errors[:"contract.entry_id"]).to eq ['INCOMPLETE_PROPERTY_VALUE']
    end
  end

  context 'raw error data' do

    it 'provides access to raw error data' do
      stub_request(:post, "#{datastore}/feedbacks")
        .to_return(status: 400, body: error_format_field_errors.to_json)
      record = SomeService.build
      record.save
      expect(record.errors.raw).to be
      json = JSON.parse(record.errors.raw)
      expect(json['status']).to be
      expect(json['message']).to be
      expect(json['field_errors']).to be
    end
  end
end
