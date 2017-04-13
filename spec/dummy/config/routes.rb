Rails.application.routes.draw do
  root 'application#root'
  get 'request_cycle_cache/simple' => 'request_cycle_cache#simple'
  get 'request_cycle_cache/no_caching_interceptor' => 'request_cycle_cache#no_caching_interceptor'
end
