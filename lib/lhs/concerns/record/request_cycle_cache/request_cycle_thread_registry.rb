# frozen_string_literal: true

require 'active_support'

class LHS::Record

  module RequestCycleCache
    class RequestCycleThreadRegistry
      # Using ActiveSupports PerThreadRegistry to be able to support Active Support v4.
      # Will switch to thread_mattr_accessor (which comes with Activesupport) when we dropping support for Active Support v5.
      extend ActiveSupport::PerThreadRegistry
      attr_accessor :request_id
    end
  end
end
