# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  describe '#dup' do
    before do
      class Appointment < LHS::Record
      end
    end

    it 'returns a copy of an object' do
      appointment = Appointment.new
      copy = appointment.dup
      expect(copy.inspect).to match(/Appointment/)
      expect(copy).to be_kind_of(Appointment)
      expect(copy.object_id).not_to eql(appointment.object_id)
    end
  end
end
