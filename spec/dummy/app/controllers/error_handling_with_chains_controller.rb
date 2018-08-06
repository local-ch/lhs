class ErrorHandlingWithChainsController < ApplicationController
  
  def handle
    @records = Record.handle(LHC::Error, ->(error){ error_callback(error) }).find(1)
  end

  def error_callback(error)
    @error = error
    render 'error'
    [Record.new]
  end
end
