# frozen_string_literal: true

require 'lhs'
require 'lhs/test/stub'

RSpec.configure do |config|
  config.before(:each) do
    LHS.config.request_cycle_cache.clear
  end
end
