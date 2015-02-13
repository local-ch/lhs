require 'active_support'
require File.dirname(__FILE__) + '/../../proxy'

class LHS::Item < LHS::Proxy

  module Update
    extend ActiveSupport::Concern

    def update(params)
      update!(params)
    rescue LHC::Error => e
      self.errors = LHS::Errors.new(e.response)
      false
    end

    def update!(params)
      service = _data_._root_._service_
      data = _data_._raw_.dup
      response = service.instance.request(method: :post, url: href, body: data.merge(params).to_json, headers: {'Content-Type' => 'application/json'})
      self._data_.merge!(response)
      true
    end
  end
end
