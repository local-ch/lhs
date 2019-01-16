require 'rails_helper'

describe LHS::Item do
  before do
    class Record < LHS::Record
      endpoint 'http://dataste/records'
    end

    stub_request(:post, "http://dataste/records")
      .to_return(
        status: 400,
        body: {
          field_errors: [{
            "code" => "UNSUPPORTED_PROPERTY_VALUE",
            "path" => ["name"]
          }]
        }.to_json
      )

    I18n.reload!
    I18n.backend.store_translations(:en, YAML.safe_load(translation)) if translation.present?
  end

  let(:errors) { Record.create(name: 'Steve').errors }

  context 'detailed error translation for record and attribute' do
    let(:translation) do
      %q{
        lhs:
          errors:
            records:
              record:
                attributes:
                  name:
                    unsupported_property_value: 'This value is not supported'
      }
    end

    it 'translates errors automatically when they are around' do
      expect(errors[:name]).to eq ['This value is not supported']
    end
  end

  context 'error translation for record' do
    let(:translation) do
      %q{
        lhs:
          errors:
            records:
              record:
                unsupported_property_value: 'This value is unfortunately not supported'
      }
    end

    it 'translates errors automatically when they are around' do
      expect(errors[:name]).to eq ['This value is unfortunately not supported']
    end
  end

  context 'error translation for message' do
    let(:translation) do
      %q{
        lhs:
          errors:
            messages:
              unsupported_property_value: 'This value is sadly not supported'
      }
    end

    it 'translates errors automatically when they are around' do
      expect(errors[:name]).to eq ['This value is sadly not supported']
    end
  end

  context 'error translation for attributes' do
    let(:translation) do
      %q{
        lhs:
          errors:
            attributes:
              name:
                unsupported_property_value: 'This value is not supported – bummer'
      }
    end

    it 'translates errors automatically when they are around' do
      expect(errors[:name]).to eq ['This value is not supported – bummer']
    end
  end

  context 'error translation for fallback message' do
    let(:translation) do
      %q{
        lhs:
          errors:
            fallback_message: 'This value is wrong'
      }
    end

    it 'translates errors automatically when they are around' do
      expect(errors[:name]).to eq ['This value is wrong']
    end
  end

  context 'detailed record attribute over other translations' do
    let(:translation) do
      %q{
        lhs:
          errors:
            fallback_message: 'This value is wrong'
            attributes:
              name:
                unsupported_property_value: 'This value is not supported – bummer'
            messages:
              unsupported_property_value: 'This value is sadly not supported'
            records:
              record:
                unsupported_property_value: 'This value is unfortunately not supported'
                attributes:
                  name:
                    unsupported_property_value: 'This value is not supported'
      }
    end

    it 'takes detailed record attribute over other translations' do
      expect(errors[:name]).to eq ['This value is not supported']
    end
  end

  context 'record translations over global messages, attributes and fallback' do
    let(:translation) do
      %q{
        lhs:
          errors:
            fallback_message: 'This value is wrong'
            attributes:
              name:
                unsupported_property_value: 'This value is not supported – bummer'
            messages:
              unsupported_property_value: 'This value is sadly not supported'
            records:
              record:
                unsupported_property_value: 'This value is unfortunately not supported'
      }
    end

    it 'takes detailed record attribute over other translations' do
      expect(errors[:name]).to eq ['This value is unfortunately not supported']
    end
  end

  context 'global message translation over attributes and fallback' do
    let(:translation) do
      %q{
        lhs:
          errors:
            fallback_message: 'This value is wrong'
            attributes:
              name:
                unsupported_property_value: 'This value is not supported – bummer'
            messages:
              unsupported_property_value: 'This value is sadly not supported'
      }
    end

    it 'takes detailed record attribute over other translations' do
      expect(errors[:name]).to eq ['This value is sadly not supported']
    end
  end

  context 'global attributes over fallback' do
    let(:translation) do
      %q{
        lhs:
          errors:
            fallback_message: 'This value is wrong'
            attributes:
              name:
                unsupported_property_value: 'This value is not supported – bummer'
      }
    end

    it 'takes detailed record attribute over other translations' do
      expect(errors[:name]).to eq ['This value is not supported – bummer']
    end
  end

  context 'no translation' do
    let(:translation) do
      %q{}
    end

    it 'takes no translation but keeps on storing the error message/code' do
      expect(errors[:name]).to eq ['UNSUPPORTED_PROPERTY_VALUE']
    end
  end

  context 'error translation for nested record' do
    before do
      class AppointmentProposal < LHS::Record
        endpoint 'http://dataste/appointment_proposals'
        endpoint 'http://dataste/appointment_proposals/{id}'

        has_many :appointments
      end

      class Appointment < LHS::Record
      end

      stub_request(:get, 'http://dataste/appointment_proposals/1')
        .to_return(body: {
          appointments: [
            { 'date_time' => '13.12.2018' },
            { 'date_time' => '18.10.2028' }
          ]
        }.to_json)

      stub_request(:post, 'http://dataste/appointment_proposals')
        .to_return(
          status: 400,
          body: {
            field_errors: [{
              'code' => 'DATE_PROPERTY_NOT_IN_FUTURE',
              'path' => ['appointments', 0, 'date_time']
            }]
          }.to_json
        )
    end

    let(:translation) do
      %q{
        lhs:
          errors:
            records:
              appointment_proposal:
                attributes:
                  appointments:
                    date_time:
                      date_property_not_in_future: 'You cannot select a date in the past.'
      }
    end

    it 'translates errors automatically when they are around' do
      appointment_proposal = AppointmentProposal.find(1)
      appointment_proposal.update(
        'appointments_attributes' => {
          '0' => { 'date_time' => '13.12.2018' },
          '1' => { 'date_time' => '18.10.2028' }
        }
      )
      expect(appointment_proposal.appointments[0].errors[:date_time]).to eql(['You cannot select a date in the past.'])
      expect(appointment_proposal.appointments[1].errors[:date_time]).to eql([])
    end
  end
end
