require 'active_support'

class LHS::Service

  module Model
    extend ActiveSupport::Concern

    module ClassMethods

      def model_name
        ActiveModel::Name.new(self.class)
      end
    end
  end
end
