# frozen_string_literal: true

class DummyCustomer < Providers::CustomerSystem
  module SomeConcern
    extend ActiveSupport::Concern

    # dont auto load this again with LHS as it would raise an exception
  end
end
