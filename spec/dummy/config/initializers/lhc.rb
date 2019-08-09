# frozen_string_literal: true

LHC.configure do |config|
  config.interceptors = [LHS::ExtendedRollbar]
end
