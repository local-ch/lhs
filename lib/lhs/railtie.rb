module LHS
  class Railtie < Rails::Railtie
    initializer "lhs.hook_into_controller_initialization" do

      class ActionController::Base
        before_filter :prepare_lhs_request_cycle_cache
        after_filter do
          puts ":: AFTER FILTER: #{LHS::Record::RequestCycleCache::RequestCycleThreadRegistry.request_id}"
        end

        private

        def prepare_lhs_request_cycle_cache
          puts "==================== BEFORE BEFORE FILTER: #{LHS::Record::RequestCycleCache::RequestCycleThreadRegistry.request_id}"
          LHS::Record::RequestCycleCache::RequestCycleThreadRegistry.request_id = request.object_id
          puts ":: BEFORE FILTER: #{LHS::Record::RequestCycleCache::RequestCycleThreadRegistry.request_id}"
        end
      end
    end
  end
end
