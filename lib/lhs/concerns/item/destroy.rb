require 'active_support'
require File.dirname(__FILE__) + '/../../proxy'

class LHS::Item < LHS::Proxy

  module Destroy
    extend ActiveSupport::Concern

    def destroy
      record = _data._root._record_class
      _data._request = record.request(method: :delete, url: href)._request
      _data
    end
  end
end
