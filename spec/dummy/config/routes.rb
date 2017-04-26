Rails.application.routes.draw do
  root 'application#root'
  get 'request_cycle_cache/simple' => 'request_cycle_cache#simple'
  get 'request_cycle_cache/no_caching_interceptor' => 'request_cycle_cache#no_caching_interceptor'
  get 'request_cycle_cache/parallel' => 'request_cycle_cache#parallel'
  get 'request_cycle_cache/headers' => 'request_cycle_cache#headers'
end
