# frozen_string_literal: true

require 'active_support'

module LHS
  module OAuth
    extend ActiveSupport::Concern

    included do
      prepend_before_action :lhs_store_oauth_access_token
    end

    private

    def lhs_store_oauth_access_token
      lhs_check_auto_oauth_enabled!
      LHS::Interceptors::AutoOauth::ThreadRegistry.access_token = instance_exec(&LHS.config.auto_oauth)
    end

    def lhs_check_auto_oauth_enabled!
      return if LHS.config.auto_oauth.present? && LHS.config.auto_oauth.is_a?(Proc)
      raise 'You have to enable LHS.config.auto_oauth by passing a proc returning an access token!'
    end
  end
end
