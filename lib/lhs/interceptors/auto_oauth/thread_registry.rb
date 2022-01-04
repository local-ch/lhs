# frozen_string_literal: true

require 'active_support'

module LHS
  module Interceptors
    module AutoOauth
      extend ActiveSupport::Concern

      class ThreadRegistry
        thread_mattr_accessor :access_token
      end
    end
  end
end
