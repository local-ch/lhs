RSpec.configure do |config|

  config.before(:each) do
    LHS::Service::Endpoints.all = {}
  end
end
