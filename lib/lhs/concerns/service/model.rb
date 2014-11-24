require 'active_support'
require 'active_model'

class LHS::Service

  module Model
    extend ActiveSupport::Concern

    module ClassMethods

      def model_name
        ActiveModel::Name.new(self)
      end
    end
  end
end
