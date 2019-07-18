# frozen_string_literal: true

require 'rails_helper'

describe LHS::OptionBlocks do
  let(:status) { 200 }

  before do
    class Record < LHS::Record
      endpoint 'http://records'
    end

    stub_request(:get, 'http://records/?id=1234')
      .with(headers: { 'Tracking-Id' => 1 })
      .to_return(status: status)
  end

  it 'allows to apply options to all requests made within a certain block' do
    LHS.options(headers: { 'Tracking-Id': 1 }) do
      Record.find(1234)
    end
  end

  it 'ensures that option blocks are reset after the block has been executed' do
    expect(LHS::OptionBlocks::CurrentOptionBlock.options).to eq nil
    LHS.options(headers: { 'Tracking-Id': 1 }) do
      Record.find(1234)
    end
    expect(LHS::OptionBlocks::CurrentOptionBlock.options).to eq nil
  end

  context 'failing request' do
    let(:status) { 400 }

    it 'ensures that option blocks are reset when an exception occures in the block' do
      expect(LHS::OptionBlocks::CurrentOptionBlock.options).to eq nil
      LHS.options(headers: { 'Tracking-Id': 1 }) do
        begin
          Record.find(1234)
        rescue LHC::Error
        end
      end
      expect(LHS::OptionBlocks::CurrentOptionBlock.options).to eq nil
    end
  end
end
