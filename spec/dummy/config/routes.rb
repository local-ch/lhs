Rails.application.routes.draw do
  root 'application#root'
  get 'request_cycle_cache/simple' => 'request_cycle_cache#simple'
end
