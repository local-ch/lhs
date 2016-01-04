RSpec.configure do |config|

  config.before(:each) do
    LHS::Record::Endpoints.all = {}
  end
end
