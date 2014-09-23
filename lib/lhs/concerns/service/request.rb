require 'active_support'

class LHS::Service

  module Request
    extend ActiveSupport::Concern

    def request(params)
      LHS::Request.new(params)
    end
  end
end
