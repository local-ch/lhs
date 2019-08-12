# frozen_string_literal: true

class ExtendedRollbarController < ApplicationController

  def extended_rollbar
    puts "BEFORE REQUEST 1"
    Record.where(color: 'blue').fetch
    puts "BEFORE REQUEST 2"
    Record.where(color: 'red').fetch
    puts "BEFORE RAISE"
    raise "Let's see if rollbar logs information about what kind of requests where made around here!"
    puts "AFTER RAISE"
  end
end
