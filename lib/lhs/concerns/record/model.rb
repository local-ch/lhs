require 'active_support'
require 'active_model'

class LHS::Record

  module Model
    extend ActiveSupport::Concern

    def to_model
      self
    end

    def persisted?
      !href.nil?
    end

    included do
      extend ActiveModel::Naming
    end
  end
end
