# frozen_string_literal: true

require 'active_support'

class LHS::Record

  module First
    extend ActiveSupport::Concern

    module ClassMethods
      def first(options = nil)
        find_by({}, options)
      end

      def first!(options = nil)
        find_by!({}, options)
      end
    end
  end
end
