module LHS
  class Railtie < Rails::Railtie
    initializer "lhs.hook_into_controller_initialization" do
      class ActionController::Base
        before_filter :lhs_request_cycle_cache

        private

        def lhs_request_cycle_cache
          LHS::Record::RequestCycleCache::RequestCycleThreadRegistry.request_id = request.object_id
        end
      end
    end
  end
end
