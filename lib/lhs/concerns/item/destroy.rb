require 'active_support'

class LHS::Item < LHS::Proxy

  module Destroy
    extend ActiveSupport::Concern

    def destroy
      service_instance = _data_._root_._service_.instance
      service_instance.request(method: :delete, url: href)
      _data_
    end
  end
end
