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

RSpec.configure do |config|
  config.before(:each) do |spec|
    next if spec.metadata.key?(:cleanup_before) && spec.metadata[:cleanup_before] == false
    LHC::Config.instance._cleanup
    LHS::Record::Endpoints.all = {}
    LHS::Record::CHILDREN.each do |child|
      child.endpoints = [] if !child.name['LHS'] && defined?(child.endpoints)
      child.configuration({}) if !child.name['LHS']
    end
  end
end
