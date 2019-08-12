# frozen_string_literal: true

require 'active_support'

module LHS
  module Interceptors
    module ExtendedRollbar
      extend ActiveSupport::Concern

      class Interceptor < LHC::Interceptor
        def after_response
          return unless LHS::Interceptors::ExtendedRollbar::ThreadRegistry.log
          LHS::Interceptors::ExtendedRollbar::ThreadRegistry.log.push(
            request: request,
            response: response
          )
          puts "LOG: #{LHS::Interceptors::ExtendedRollbar::ThreadRegistry.log.to_json}"
        end
      end
    end
  end

  const_set('ExtendedRollbar', LHS::Interceptors::ExtendedRollbar::Interceptor)
end
