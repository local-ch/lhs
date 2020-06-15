# frozen_string_literal: true

require 'active_support'

module LHS
  module Interceptors
    module AutoOauth
      extend ActiveSupport::Concern

      class Interceptor < LHC::Interceptor

        def before_request
          return unless LHS.config.auto_oauth
          binding.pry
        end
      end
    end
  end
end
