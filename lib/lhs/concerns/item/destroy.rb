require 'active_support'

class LHS::Item < LHS::Proxy

  module Destroy
    extend ActiveSupport::Concern

    def destroy
      service_instance = _data_._root_._service_.instance
      _data_._request_ = service_instance.request(method: :delete, url: href)._request_
      _data_
    end
  end
end
