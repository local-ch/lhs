# frozen_string_literal: true

require 'lhs'

RSpec.configure do |config|
  config.before(:each) do
    LHS.config.request_cycle_cache.clear
  end
end
