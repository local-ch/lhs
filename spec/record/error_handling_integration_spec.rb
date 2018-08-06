require 'rails_helper'
require 'lhc/test/cache_helper.rb'

describe 'Request Cycle Cache', type: :request do
  let!(:request) do
    stub_request(:get, "http://datastore/v2/records?color=blue")
      .to_return(status: 404)
  end

  it 'handles errors in rails controllers', cleanup_before: false do
    get '/error_handling_with_chains/handle'
    expect(request).to have_been_made.once
    expect(response.body).to include('There was an error')
  end
end
