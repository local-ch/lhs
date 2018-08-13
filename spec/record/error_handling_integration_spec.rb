require 'rails_helper'
require 'lhc/test/cache_helper.rb'

describe 'Error handling with chains', type: :request do
  let!(:request) do
    stub_request(:get, "http://datastore/v2/records?color=blue")
      .to_return(status: 404)
  end

  it 'handles errors in rails controllers when query resolved in controller',
  dummy_models: true do
    get '/error_handling_with_chains/fetch_in_controller'
    expect(request).to have_been_made.once
    expect(response.body).to include('Sorry there was an error.')
  end

  it 'handles errors in rails controllers when query resolved in view',
  dummy_models: true do
    get '/error_handling_with_chains/fetch_in_view'
    expect(request).to have_been_made.once
    expect(response.body).to include('Sorry there was an error.')
  end
end
