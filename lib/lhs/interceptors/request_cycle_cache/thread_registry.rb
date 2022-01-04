# frozen_string_literal: true

require 'active_support'

module LHS
  module Interceptors
    module RequestCycleCache
      extend ActiveSupport::Concern

      class ThreadRegistry
        thread_mattr_accessor :request_id
      end
    end
  end
end
