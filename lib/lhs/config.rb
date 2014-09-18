require 'singleton'

class LHS::Config
  include Singleton

  attr_accessor :config

  def initialize
    self.config = YAML.load_file(File.join(__dir__, '..', 'lhs.config.yml'))
  end

  def self.[](key)
    setting = LHS::Config.instance.config[key.to_s]
    (setting[Rails.env] || setting['others']) if setting
  end
end
