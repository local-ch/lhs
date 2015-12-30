require 'active_support'
require File.dirname(__FILE__) + '/../../proxy'

class LHS::Item < LHS::Proxy

  module Destroy
    extend ActiveSupport::Concern

    def destroy
      service = _data._root._service
      _data._request = service.request(method: :delete, url: href)._request
      _data
    end
  end
end
