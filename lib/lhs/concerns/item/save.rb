require 'active_support'

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
      service = _data_._root_._service_
      data = _data_._raw_.dup
      url = href if href
      url ||= service.instance.find_endpoint(params).compile(params)
      response = service.instance.request(method: :post, url: url, body: data.to_json, headers: {'Content-Type' => 'application/json'})
      self._data_.merge!(response)
      true
    end
  end
end
