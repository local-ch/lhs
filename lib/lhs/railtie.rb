# frozen_string_literal: true

module LHS
  class Railtie < Rails::Railtie
    initializer "lhs.hook_into_controller_initialization" do
      class ActionController::Base

        def initialize
          prepare_lhs_request_cycle_cache
          reset_option_blocks
          super
        end

        private

        def prepare_lhs_request_cycle_cache
          return unless LHS.config.request_cycle_cache_enabled
          LHS::Record::RequestCycleCache::RequestCycleThreadRegistry.request_id = [Time.now.to_f, request.object_id].join('#')
        end

        def reset_option_blocks
          LHS::OptionBlocks::CurrentOptionBlock.options = nil
        end
      end
    end
  end
end
