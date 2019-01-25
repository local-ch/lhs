# frozen_string_literal: true

class RequestCycleCacheController < ApplicationController
  def simple
    User.find(1) # first request
    user = User.find(1) # second request that should be serverd from request cycle cache
    render json: user.to_json
  end

  def no_caching_interceptor
    User.options(interceptors: []).find(1) # first request
    user = User.options(interceptors: []).find(1) # second request
    render json: user.to_json
  end

  def parallel
    User.find(1, 2) # first request
    users = User.find(1, 2) # second request that should be serverd from request cycle cache
    render json: users.to_json
  end

  def headers
    User.find(1) # first request
    user = User.options(headers: { 'Authentication' => 'Bearer 123' }).find(1) # second request that should NOT be serverd from request cycle cache as the headers are different
    render json: user.to_json
  end
end
