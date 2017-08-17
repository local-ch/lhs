require 'singleton'

class LHS::Config
  include Singleton

  attr_accessor :request_cycle_cache_enabled, :request_cycle_cache

  def initialize
    self.request_cycle_cache_enabled ||= true
    if defined?(ActiveSupport::Cache::MemoryStore)
      self.request_cycle_cache ||= ActiveSupport::Cache::MemoryStore.new
    end
  end
end
