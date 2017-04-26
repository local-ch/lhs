require 'rails_helper'
require 'lhc/test/cache_helper.rb'

describe 'Request Cycle Cache', type: :request do
  let!(:request) do
    stub_request(:get, "http://datastore/v2/users/1").to_return(body: { name: 'Steve' }.to_json)
  end

  let!(:second_request) do
    stub_request(:get, "http://datastore/v2/users/2").to_return(body: { name: 'Peter' }.to_json)
  end

  before(:each) do
    class User < LHS::Record
      endpoint 'http://datastore/v2/users'
      endpoint 'http://datastore/v2/users/:id'
    end
    LHC.configure do |config|
      config.interceptors = [LHC::Caching]
    end
  end

  it 'serves requests that are exactly the same during one request cycle from the cache',
  cleanup_before: false, request_cycle_cache: true do
    get '/request_cycle_cache/simple'
    expect(request).to have_been_made.once

    # Second Request, Second Cycle, requests again
    get '/request_cycle_cache/simple'
    expect(request).to have_been_made.times(2)
  end

  it 'does not serve from request cycle cache when cache interceptor is not hooked in, but logs a warning',
  cleanup_before: false, request_cycle_cache: true do
    expect(lambda do
      get '/request_cycle_cache/no_caching_interceptor'
    end).to output(
      %r{\[WARNING\] Can't enable LHS::RequestCycleCache as LHC::Caching interceptor is not enabled/configured \(see https://github.com/local-ch/lhc/blob/master/docs/interceptors/caching.md#caching-interceptor\)!}
    ).to_stderr
    expect(request).to have_been_made.times(2)
  end

  it 'serves requests also from cache when LHS/LHC makes requests in parallel',
  cleanup_before: false, request_cycle_cache: true do
    get '/request_cycle_cache/parallel'
    expect(request).to have_been_made.once
    expect(second_request).to have_been_made.once
  end

  it 'sets different uniq request ids as base for request cycle caching for different requests',
  cleanup_before: false, request_cycle_cache: true do
    get '/request_cycle_cache/simple'
    first_request_id = LHS::Record::RequestCycleCache::RequestCycleThreadRegistry.request_id
    second_request_id = nil
    thread = Thread.new do
      get '/request_cycle_cache/simple'
      second_request_id = LHS::Record::RequestCycleCache::RequestCycleThreadRegistry.request_id
    end
    thread.join
    expect(first_request_id).not_to eq second_request_id
  end

  context 'disabled request cycle cache' do
    it 'does not serve from request cycle cache when cache interceptor is not hooked in, and does not warn if request cycle cache is explicitly disabled',
    cleanup_before: false do
      expect(lambda do
        get '/request_cycle_cache/no_caching_interceptor'
      end).not_to output(
        %r{\[WARNING\] Can't enable LHS::RequestCycleCache as LHC::Caching interceptor is not enabled/configured \(see https://github.com/local-ch/lhc/blob/master/docs/interceptors/caching.md#caching-interceptor\)!}
      ).to_stderr
      expect(request).to have_been_made.times(2)
    end

    it 'DOES NOT serve requests that are exactly the same during one request cycle from the cache, when request cycle cache is disabled',
    cleanup_before: false do
      get '/request_cycle_cache/simple'
      expect(request).to have_been_made.times(2)
    end
  end

  context 'headers' do

    it 'considers the request headers when setting the cache key',
    cleanup_before: false, request_cycle_cache: true do
      get '/request_cycle_cache/headers'
      expect(request).to have_been_made.times(2)
    end
  end
end
