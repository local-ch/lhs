# frozen_string_literal: true

class ExtendedRollbarController < ApplicationController

  def extended_rollbar
    Record.where(color: 'blue').fetch
    Record.where(color: 'red').fetch
    raise "Let's see if rollbar logs information about what kind of requests where made around here!"
  end
end
