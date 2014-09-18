ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end
