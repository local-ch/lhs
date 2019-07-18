# frozen_string_literal: true

class OptionBlocksController < ApplicationController

  def first
    LHS::OptionBlocks::CurrentOptionBlock.options = { params: { request: 'first' } }
    Record.where(request: 'second')
  end

  def second
    Record.where(request: 'second')
  end
end
