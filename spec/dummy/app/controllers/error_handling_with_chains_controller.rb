class ErrorHandlingWithChainsController < ApplicationController
  def handle
    @records = Record.handle(LHC::Error, ->(error) { error_callback(error) }).find(id: 1)
  end

  private

  def error_callback(error)
    @error = error
    render 'error'
    [Record.new]
  end
end
