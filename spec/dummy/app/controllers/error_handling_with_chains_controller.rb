# frozen_string_literal: true

class ErrorHandlingWithChainsController < ApplicationController

  # Example where the query chain is resolved
  # in the view (during render 'show')
  def fetch_in_view
    @records = DummyRecord
      .handle(LHC::Error, ->(error) { handle_error(error) })
      .where(color: 'blue')
    render 'show'
    render_error if @error
  end

  # Example where the query chain is resolved
  # before the view is rendered
  def fetch_in_controller
    @records = DummyRecord
      .handle(LHC::Error, ->(error) { handle_error(error) })
      .where(color: 'blue').fetch
    render 'show'
    render_error if @error
  end

  private

  def handle_error(error)
    @error = error
    nil
  end

  def render_error
    self.response_body = nil
    render 'error'
  end
end
