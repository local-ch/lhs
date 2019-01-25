# frozen_string_literal: true

RSpec.configure do |config|
  config.before do |spec|
    enabled = spec.metadata.key?(:request_cycle_cache) && spec.metadata[:request_cycle_cache] == true
    enabled ||= false
    LHS.config.request_cycle_cache_enabled = enabled
    LHS.config.request_cycle_cache = ActiveSupport::Cache::MemoryStore.new
  end
end
