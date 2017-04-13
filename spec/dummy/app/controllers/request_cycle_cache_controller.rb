class RequestCycleCacheController < ApplicationController
  
  def simple
    user = User.find(1) # first request
    user = User.find(1) # second request that should be serverd from request cycle cache
    render json: user.to_json
  end

  def no_caching_interceptor
    user = User.options(interceptors: []).find(1)
    user = User.options(interceptors: []).find(1)
    render json: user.to_json
  end
end
