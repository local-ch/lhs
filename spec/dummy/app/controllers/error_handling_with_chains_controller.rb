class ErrorHandlingWithChainsController < ApplicationController
  def handle
    @records = Record
      .handle(LHC::Error, ->(error) { error_callback(error) })
      .where(color: 'blue')
  end

  private

  def error_callback(error)
    @error = error
    render 'error'
    [Record.new]
  end
end
