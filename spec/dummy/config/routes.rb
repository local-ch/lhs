Rails.application.routes.draw do
  root 'application#root'

  # Request Cycle Cache
  get 'request_cycle_cache/simple' => 'request_cycle_cache#simple'
  get 'request_cycle_cache/no_caching_interceptor' => 'request_cycle_cache#no_caching_interceptor'
  get 'request_cycle_cache/parallel' => 'request_cycle_cache#parallel'
  get 'request_cycle_cache/headers' => 'request_cycle_cache#headers'
  
  # Error handling with chains
  get 'error_handling_with_chains/handle' => 'error_handling_with_chains#handle'
end
