require 'active_support'
require File.dirname(__FILE__) + '/../../proxy'

class LHS::Item < LHS::Proxy

  module Destroy
    extend ActiveSupport::Concern

    def destroy
      service_instance = _data._root._service.instance
      _data._request = service_instance.request(method: :delete, url: href)._request
      _data
    end
  end
end
