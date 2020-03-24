# frozen_string_literal: true

class OptionBlocksController < ApplicationController

  def first
    LHS::OptionBlocks::CurrentOptionBlock.options = { params: { request: 'first' } }
    DummyRecord.where(request: 'second').fetch
    render text: 'ok'
  end

  def second
    DummyRecord.where(request: 'second').fetch
    render text: 'ok'
  end
end
