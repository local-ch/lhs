module LHS
  class Railtie < Rails::Railtie
    initializer "lhs.hook_into_controller_initialization" do
      class ActionController::Base
        before_filter :prepare_lhs_request_cycle_cache

        private

        def prepare_lhs_request_cycle_cache
          return unless LHS.config.request_cycle_cache_enabled
          LHS::Record::RequestCycleCache::RequestCycleThreadRegistry.request_id = [Time.now.to_f, request.object_id].join('#')
        end
      end
    end
  end
end
