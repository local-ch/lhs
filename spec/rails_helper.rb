require 'spec_helper'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'

ENV["RAILS_ENV"] ||= 'test'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end
