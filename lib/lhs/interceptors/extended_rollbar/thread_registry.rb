# frozen_string_literal: true

require 'active_support'

module LHS
  module Interceptors
    module ExtendedRollbar
      extend ActiveSupport::Concern

      class ThreadRegistry
        thread_mattr_accessor :log
      end
    end
  end
end
