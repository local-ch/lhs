require 'singleton'

class LHS::Config
  include Singleton

  attr_accessor :request_cycle_cache_enabled

  def initialize
    self.request_cycle_cache_enabled ||= true
  end
end
