# frozen_string_literal: true

require 'singleton'

class LHS::Config
  include Singleton

  attr_accessor :request_cycle_cache_enabled, :request_cycle_cache, :trace

  def initialize
    self.request_cycle_cache_enabled ||= true
    self.trace ||= false
    if defined?(ActiveSupport::Cache::MemoryStore)
      self.request_cycle_cache ||= ActiveSupport::Cache::MemoryStore.new
    end
  end

  def reset
    self.request_cycle_cache_enabled = nil
    self.trace = nil
    self.request_cycle_cache = nil
    initialize
  end
end
