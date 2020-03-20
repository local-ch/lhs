# frozen_string_literal: true

require 'lhs'
require 'lhs/test/stubbable_records'

RSpec.configure do |config|
  config.before(:each) do
    LHS.config.request_cycle_cache.clear
  end
end
