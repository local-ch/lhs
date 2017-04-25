require 'active_support'

class LHS::Record

  module RequestCycleCache
    class RequestCycleThreadRegistry
      extend ActiveSupport::PerThreadRegistry
      attr_accessor :request_id
    end
  end
end
