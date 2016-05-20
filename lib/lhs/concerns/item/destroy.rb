require 'active_support'
require File.dirname(__FILE__) + '/../../proxy'

class LHS::Item < LHS::Proxy

  module Destroy
    extend ActiveSupport::Concern

    def destroy(options = {})
      options ||= {}
      _data._request = _data.class.request(options.merge(method: :delete, url: href))._request
      _data
    end
  end
end
