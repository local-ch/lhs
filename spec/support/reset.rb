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

  DESCENDANTS = []

  def self.inherited(child)
    DESCENDANTS.push(child)
    child.singleton_class.class_eval do
      define_method(:inherited) do |grand_child|
        DESCENDANTS.push(grand_child)
      end
    end
    super
  end

end

def reset_lhc
  LHC::Config.instance._cleanup
end

def reset_lhs
  LHS::Record::Endpoints.all = {}
  LHS::Record::DESCENDANTS.each do |decendant|
    decendant.endpoints = [] if !decendant.name['LHS'] && defined?(decendant.endpoints)
    decendant.configuration({}) if !decendant.name['LHS']
    # Object.send(:remove_const, decendant.name.deconstantize.to_sym) if Object.constants.include?(decendant.name.deconstantize.to_sym)
  end
end

RSpec.configure do |config|
  config.before do |spec|
    reset_lhc unless spec.metadata.key?(:reset_before) && spec.metadata[:reset_before] == false
    reset_lhs unless spec.metadata.key?(:reset_before) && spec.metadata[:reset_before] == false
    klasses = []
    Dir.glob(Rails.root.join('app', 'models', '**', '*.rb')).each do |file|
      next unless File.read(file).match('LHS::Record')
      load file
      klasses << file.split('models/').last.gsub('.rb', '').classify
    end
    Dir.glob(Rails.root.join('app', 'models', '**', '*.rb')).each do |file|
      next if klasses.none? { |klass| File.read(file).match(klass) }
      load file
    end
  end
end
