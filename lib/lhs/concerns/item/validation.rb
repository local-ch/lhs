require 'active_support'

class LHS::Item < LHS::Proxy

  module Validation
    extend ActiveSupport::Concern

    def valid?
      self.errors = nil
      fail 'No validation endpoint found!' unless validation_endpoint
      record = LHS::Record.for_url(validation_endpoint.url)
      params = validation_endpoint.options.fetch(:params, {}).merge(persist: false)
      begin
        record.request(
          url: validation_endpoint.url,
          method: :post,
          params: params,
          body: _data.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        true
      rescue LHC::Error => e
        self.errors = LHS::Errors.new(e.response)
        false
      end
    end
    alias validate valid?

    private

    def validation_endpoint
      endpoint = _data._record_class.find_endpoint(_data._raw)
      endpoint ||= LHS::Endpoint.for_url(_data.href) if _data.href
      validates = endpoint.options && endpoint.options.fetch(:validates, false)
      fail 'Endpoint does not support validations!' unless validates
      endpoint
    end
  end
end
