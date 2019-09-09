# frozen_string_literal: true

require 'lhs'
require 'lhs/test/stub'

RSpec.configure do |config|
  config.before(:each) do
    LHS.config.request_cycle_cache.clear
  end

  config.before(:all) do

    module LHS
      def self.stub
        LHS::Test::Stub
      end
    end
  end
end
