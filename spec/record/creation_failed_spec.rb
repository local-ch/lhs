require 'rails_helper'

describe LHS::Record do

  context 'creation failed' do

    let(:datastore) { 'http://local.ch/v2' }

    before(:each) do
      LHC.config.placeholder(:datastore, datastore)
      class Record < LHS::Record
        endpoint ':datastore/:campaign_id/feedbacks'
        endpoint ':datastore/feedbacks'
      end
    end

    let(:error_message) { "ratings must be set when review or name or review_title is set | The property value is required; it cannot be null, empty, or blank." }

    let(:creation_error) do
      {
        "status" => 400,
        "message" => error_message,
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
      stub_request(:post, "#{datastore}/feedbacks")
        .to_return(status: 400, body: creation_error.to_json)
      record = Record.create(name: 'Steve')
      expect(record).to be_kind_of Record
      expect(record.errors).to be
      expect(record.name).to eq 'Steve'
      expect(record.errors.include?(:ratings)).to eq true
      expect(record.errors.include?(:recommended)).to eq true
      expect(record.errors[:ratings]).to eq ['REQUIRED_PROPERTY_VALUE']
      expect(record.errors.messages).to eq({:ratings=>["REQUIRED_PROPERTY_VALUE"], :recommended=>["REQUIRED_PROPERTY_VALUE"]})
      expect(record.errors.message).to eq error_message
    end

    it 'doesnt fail when no fields are provided by the backend' do
      stub_request(:post, "#{datastore}/feedbacks")
      .to_return(status: 400, body: {}.to_json)
      Record.create(name: 'Steve')
    end
  end
end
