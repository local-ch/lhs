class LHS::Service

  CHILDREN = []

  def self.inherited(child)
    CHILDREN.push(child)
    super
  end

end


RSpec.configure do |config|

  config.before(:each) do
    LHS::Service::CHILDREN.each do |child|
      child.instance.endpoints = [] if !child.name['LHS']
    end
  end
end
