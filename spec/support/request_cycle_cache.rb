RSpec.configure do |config|
  config.before(:each) do |spec|
    enabled = spec.metadata.key?(:request_cycle_cache) && spec.metadata[:request_cycle_cache] == true
    enabled ||= false
    LHS.config.request_cycle_cache_enabled = enabled
  end
end
