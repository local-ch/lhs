class RequestCycleCacheController < ApplicationController
  def simple
    user = User.find(1) || # first request
      User.find(1) # second request that should be serverd from request cycle cache
    render json: user.to_json
  end

  def no_caching_interceptor
    user = User.options(interceptors: []).find(1) || # first request
      User.options(interceptors: []).find(1) # second request
    render json: user.to_json
  end

  def parallel
    users = User.find(1, 2) || # first request
      User.find(1, 2) # second request that should be serverd from request cycle cache
    render json: users.to_json
  end
end
