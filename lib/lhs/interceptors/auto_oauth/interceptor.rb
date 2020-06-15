# frozen_string_literal: true

require 'active_support'

module LHS
  module Interceptors
    module AutoOauth
      extend ActiveSupport::Concern

      class Interceptor < LHC::Interceptor

        def before_request
          request.options[:auth] = { bearer: token }
        end

        def tokens
          @tokens ||= LHS::Interceptors::AutoOauth::ThreadRegistry.access_token
        end

        def token
          if tokens.is_a?(Hash)
            tokens.dig(
              request.options[:oauth] ||
              request.options[:auto_oauth] ||
              request.options[:record]&.auto_oauth
            )
          else
            tokens
          end
        end
      end
    end
  end
end
