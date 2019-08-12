# frozen_string_literal: true

if defined?(Rollbar)
  Rollbar.configure do |config|
    config.access_token = '12345'
    config.enabled = true
    config.before_process << LHS::Interceptors::ExtendedRollbar::Handler.init
  end
end
