# frozen_string_literal: true

require 'active_support'

class LHS::Record

  module HrefFor
    extend ActiveSupport::Concern

    module ClassMethods
      def href_for(args = nil)
        return unless [Integer, String].include?(args.class)
        params = { id: args }
        find_endpoint(params).compile(params)
      end
      alias url_for href_for
    end
  end
end
