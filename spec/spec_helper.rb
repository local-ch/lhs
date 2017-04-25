require 'pry'
require 'webmock/rspec'

Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.before(:each) do
    LHS.config.request_cycle_cache_enabled = false
  end
end
