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
      service_instance = _data_._root_._service_.instance
      body = _data_._raw_.to_json
      data = service_instance.request(method: :post, url: href, body: body)
      self._data_.merge!(data)
      true
    end
  end
end
