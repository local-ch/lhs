require 'active_support'
require 'active_model'

class LHS::Record

  module Model
    extend ActiveSupport::Concern

    def to_model
      self
    end

    module ClassMethods
      def model_name
        ActiveModel::Name.new(self)
      end
    end
  end
end
