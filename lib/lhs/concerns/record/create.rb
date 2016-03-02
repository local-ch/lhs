require 'active_support'

class LHS::Record

  module Create
    extend ActiveSupport::Concern

    module ClassMethods
      def create(data = {})
        record = new(data)
        record.save
        record
      end

      def create!(data = {})
        record = new(data)
        record.save!
        record
      end
    end
  end
end
