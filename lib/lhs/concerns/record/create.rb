require 'active_support'

class LHS::Record

  module Create
    extend ActiveSupport::Concern

    module ClassMethods
      def create(data = {})
        object = new(data)
        object.save
        object
      end

      def create!(data = {})
        object = new(data)
        object.save!
        object
      end
    end
  end
end
