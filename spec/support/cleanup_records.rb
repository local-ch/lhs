class LHS::Record

  CHILDREN = []

  def self.inherited(child)
    CHILDREN.push(child)
    super
  end

end

RSpec.configure do |config|
  config.before(:each) do
    LHS::Record::CHILDREN.each do |child|
      child.endpoints = [] if !child.name['LHS']
      child.configuration({}) if !child.name['LHS']
    end
  end
end
