# frozen_string_literal: true

ENV["RAILS_ENV"] ||= 'test'
ENV['DUMMYAPP_PATH'] = "spec/dummy"

require 'rails/rollbar_runner'
require 'spec_helper'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end
