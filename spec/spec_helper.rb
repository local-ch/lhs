require 'pry'
require 'webmock/rspec'

Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }
