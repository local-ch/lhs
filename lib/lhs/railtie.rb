# frozen_string_literal: true

module LHS
  class Railtie < Rails::Railtie
    initializer "lhs.hook_into_controller_initialization" do
      class ActionController::Base

        def initialize
          prepare_lhs_request_cycle_cache
          reset_lhs_auto_oauth
          reset_option_blocks
          reset_extended_rollbar_request_logs
          super
        end

        private

        def prepare_lhs_request_cycle_cache
          return unless LHS.config.request_cycle_cache_enabled
          LHS::Interceptors::RequestCycleCache::ThreadRegistry.request_id = [Time.now.to_f, request.object_id].join('#')
        end

        def reset_lhs_auto_oauth
          LHS::Interceptors::AutoOauth::ThreadRegistry.access_token = nil
        end

        def reset_option_blocks
          LHS::OptionBlocks::CurrentOptionBlock.options = nil
        end

        def reset_extended_rollbar_request_logs
          return unless defined?(::Rollbar)
          return unless LHC.config.interceptors.include?(LHS::Interceptors::ExtendedRollbar::Interceptor)
          LHS::Interceptors::ExtendedRollbar::ThreadRegistry.log = []
        end
      end
    end
  end
end
