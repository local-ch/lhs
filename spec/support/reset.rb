# frozen_string_literal: true

require 'lhc'
class LHC::Config

  def _cleanup
    @endpoints = {}
    @placeholders = {}
    @interceptors = nil
  end
end

class LHS::Record

  CHILDREN = []

  def self.inherited(child)
    CHILDREN.push(child)
    super
  end

end

def reset_lhc
  LHC::Config.instance._cleanup
end

def reset_lhs
  LHS::Record::Endpoints.all = {}
  LHS::Record::CHILDREN.each do |child|
    child.endpoints = [] if !child.name['LHS'] && defined?(child.endpoints)
    child.configuration({}) if !child.name['LHS']
  end
end

RSpec.configure do |config|
  config.before do |spec|
    reset_lhc unless spec.metadata.key?(:reset_before) && spec.metadata[:reset_before] == false
    reset_lhs unless spec.metadata.key?(:reset_before) && spec.metadata[:reset_before] == false
    next unless spec.metadata.key?(:dummy_models) && spec.metadata[:dummy_models] == true
    Dir.glob(Rails.root.join('app', 'models', '**', '*.rb')).each do |file|
      load file if File.read(file).match('LHS::Record')
    end
  end
end
