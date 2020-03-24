# frozen_string_literal: true

require 'rails_helper'

describe 'Option Blocks', type: :request do
  let!(:first_request) do
    stub_request(:get, "http://datastore/v2/records?request=first")
      .to_return(status: 200)
  end

  let!(:second_request) do
    stub_request(:get, "http://datastore/v2/records?request=second")
      .to_return(status: 200)
  end

  it 'always ensures option blocks are always reset for new requests',
  dummy_models: true, reset_before: true do
    get '/option_blocks/first'
    expect(first_request).to have_been_made.once
    get '/option_blocks/second'
    expect(second_request).to have_been_made.once
  end
end
