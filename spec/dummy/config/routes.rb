# frozen_string_literal: true

Rails.application.routes.draw do
  root 'application#root'

  # Automatic Authentication
  get 'automatic_authentication/oauth' => 'automatic_authentication#o_auth'
  get 'automatic_authentication/oauth_with_multiple_providers' => 'automatic_authentication#o_auth_with_multiple_providers'
  get 'automatic_authentication/oauth_with_provider' => 'automatic_authentication#o_auth_with_provider'

  # Request Cycle Cache
  get 'request_cycle_cache/simple' => 'request_cycle_cache#simple'
  get 'request_cycle_cache/no_caching_interceptor' => 'request_cycle_cache#no_caching_interceptor'
  get 'request_cycle_cache/parallel' => 'request_cycle_cache#parallel'
  get 'request_cycle_cache/headers' => 'request_cycle_cache#headers'

  # Error handling with chains
  get 'error_handling_with_chains/fetch_in_controller' => 'error_handling_with_chains#fetch_in_controller'
  get 'error_handling_with_chains/fetch_in_view' => 'error_handling_with_chains#fetch_in_view'

  # Option Blocks
  get 'option_blocks/first' => 'option_blocks#first'
  get 'option_blocks/second' => 'option_blocks#second'

  # Extended Rollbar
  get 'extended_rollbar' => 'extended_rollbar#extended_rollbar'
end
