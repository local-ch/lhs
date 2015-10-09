require 'active_support'
require File.dirname(__FILE__) + '/../../proxy'

class LHS::Item < LHS::Proxy

  module Save
    extend ActiveSupport::Concern

    def save
      save!
      rescue LHC::Error => e
        self.errors = LHS::Errors.new(e.response)
        false
    end

    def save!
      service = _data._root._service
      data = _data._raw.dup
      url = if href.present?
       href
      else
        service.instance.find_endpoint(data).compile(data)
      end
      data = service.instance.request(method: :post, url: url, body: data.to_json, headers: {'Content-Type' => 'application/json'})
      self._data.merge_raw!(data)
      true
    end
  end
end
