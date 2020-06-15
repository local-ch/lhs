# frozen_string_literal: true

require 'active_support'

module LHS
  module Interceptors
    module AutoOauth
      extend ActiveSupport::Concern

      class Interceptor < LHC::Interceptor

        def before_request
          request.options[:auth] = { bearer: LHS::Interceptors::AutoOauth::ThreadRegistry.access_token }
        end
      end
    end
  end
end
