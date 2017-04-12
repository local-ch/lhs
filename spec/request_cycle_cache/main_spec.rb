require 'rails_helper'

describe 'Request Cycle Cache', type: :request do

  it 'serves requests that are exactly the same during one request cycle from the cache', cleanup_before: false do
    request = stub_request(:get, "http://datastore/v2/users/1").to_return(body: { name: 'Steve' }.to_json)
    get '/request_cycle_cache/simple'
    expect(request).to have_been_made.once
    binding.pry
  end
end
