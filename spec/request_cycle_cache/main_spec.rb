require 'rails_helper'

describe 'Request Cycle Cache', type: :request do

  let!(:request) do
    stub_request(:get, "http://datastore/v2/users/1").to_return(body: { name: 'Steve' }.to_json)
  end

  it 'serves requests that are exactly the same during one request cycle from the cache', cleanup_before: false do
    get '/request_cycle_cache/simple'
    expect(request).to have_been_made.once

    # Second Request, Second Cycle, requests again
    get '/request_cycle_cache/simple'
    expect(request).to have_been_made.times(2)
  end

  it 'does not serve from request cycle cache when cache interceptor is not hooked in, but logs a warning', cleanup_before: false do
    get '/request_cycle_cache/no_caching_interceptor'
    obj.should_receive(:warn).with("Some Message")
    expect(request).to have_been_made.times(2)
  end

  it 'serves requests also from cache when LHS/LHC makes requests in parallel', cleanup_before: false do
    pending
  end
end
