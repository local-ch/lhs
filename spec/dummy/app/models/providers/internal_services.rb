# frozen_string_literal: true

module Providers
  class InternalServices < LHS::Record
    provider(auto_oauth: true)
  end
end
