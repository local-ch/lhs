require 'rails_helper'

describe LHS::Record do
  context 'custom setters' do

    context 'assigning values directly to other attributes' do

      before do
        class Booking < LHS::Record
          endpoint 'https://bookings'

          def appointment_attributes=(params)
            self.appointments = params.map { |item| item[:id] }
          end
        end
      end

      it 'allows to change raw in custom setters' do
        booking = Booking.new(appointment_attributes: [{ id: 1 }])
        expect(booking.appointments.to_a).to eq [1]
      end
    end

    context 'assign values directly by using square brackets' do

      before do
        class BookingAppointments < LHS::Record
          endpoint 'https://bookings'

          def appointment_attributes=(params)
            self[:appointments] = params.map { |item| item[:id] }
          end
        end
      end

      it 'allows to change raw in custom setters' do
        booking = BookingAppointments.new(appointment_attributes: [{ id: 1 }])
        expect(booking.appointments.to_a).to eq [1]
      end
    end
  end
end
