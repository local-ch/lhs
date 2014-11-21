require 'active_support'

class LHS::Item < LHS::Proxy

  module Save
    extend ActiveSupport::Concern

    def save
      _save_
      rescue LHC::Error => e
        self.errors = LHS::Errors.new(e.response)
        false
    end

    def save!
      _save_
    end

    private

    def _save_
      service = _data_._root_._service_
      data = _data_._raw_.dup
      url = _url_(service, data)
      response = service.instance.request(method: :post, url: url, body: data.to_json, headers: {'Content-Type' => 'application/json'})
      self._data_.merge!(response)
      true
    end

    def _url_(service, params = {})
      return href if href
      endpoint = service.instance.find_endpoint(params)
      endpoint.compile(params)
    end
  end
end
