require 'active_support'

class LHS::Record

  module RequestCycleCache
    extend ActiveSupport::Concern

    class RequestCycleThreadRegistry
      extend ActiveSupport::PerThreadRegistry
      attr_accessor :request_id
    end
  end
end
