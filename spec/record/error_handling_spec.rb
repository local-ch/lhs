# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  let(:handler) { spy('handler') }

  before do
    class Record < LHS::Record
      endpoint 'http://local.ch/v2/records'
    end
    stub_request(:get, "http://local.ch/v2/records?color=blue")
      .to_return(status: 400)
  end

  it 'allows to chain error handling' do
    expect {
      Record.where(color: 'blue').handle(LHC::Error, ->(_error) { handler.handle }).first
    }.not_to raise_error
    expect(handler).to have_received(:handle)
  end

  it 'reraises in case chained error is not matched' do
    expect {
      Record.where(color: 'blue').handle(LHC::Conflict, ->(_error) { handler.handle }).first
    }.to raise_error(LHC::Error)
    expect(handler).not_to have_received(:handle)
  end

  it 'calls all the handlers' do
    expect {
      Record.where(color: 'blue')
        .handle(LHC::Error, ->(_error) { handler.handle_1 })
        .handle(LHC::Error, ->(_error) { handler.handle_2 })
        .first
    }.not_to raise_error
    expect(handler).to have_received(:handle_1)
    expect(handler).to have_received(:handle_2)
  end
end
