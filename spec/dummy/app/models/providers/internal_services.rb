# frozen_string_literal: true

module Providers
  class InternalServices < LHS::Record
    provider(oauth: true)
  end
end
