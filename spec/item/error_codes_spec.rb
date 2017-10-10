require 'rails_helper'

describe LHS::Item do
  context 'error codes' do
    before(:each) do
      I18n.reload!
      I18n.backend.store_translations(:en, YAML.safe_load(translation)) if translation.present?
      class Record < LHS::Record
        endpoint 'http://datastore/records'
      end
    end

    let(:translation) do
      %q{
        lhs:
          errors:
            fallback_message: 'This value is wrong'
      }
    end

    it 'provides error codes along side with translated messages' do
      stub_request(:post, 'http://datastore/records')
        .to_return(body: {
          field_errors: [{
            code: 'UNSUPPORTED_PROPERTY_VALUE',
            path: ['gender'],
            message: 'The property value is unsupported.'
          }, {
            code: 'INCOMPLETE_PROPERTY_VALUE',
            path: ['gender'],
            message: 'The property value is incomplete. It misses some data'
          }, {
            code: 'INCOMPLETE_PROPERTY_VALUE',
            path: ['contract', 'entry_id'],
            message: 'The property value is incomplete. It misses some data'
          }]
        }.to_json)
      record = Record.create
      expect(record.errors.messages['gender']).to eq(
        ['This value is wrong', 'This value is wrong']
      )
      expect(record.errors.codes['gender']).to eq(
        ['UNSUPPORTED_PROPERTY_VALUE', 'INCOMPLETE_PROPERTY_VALUE']
      )
      expect(record.errors.messages['contract.entry_id']).to eq(
        ['This value is wrong']
      )
      expect(record.errors.codes['contract.entry_id']).to eq(
        ['INCOMPLETE_PROPERTY_VALUE']
      )
    end
  end
end
