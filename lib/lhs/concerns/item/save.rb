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
      params = _data_._raw_.merge(method: :post, url: href)
      service_instance.request(params)
      true
    end
  end
end
