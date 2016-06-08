require 'active_support'

class LHS::Item < LHS::Proxy

  module Validation
    extend ActiveSupport::Concern

    def valid?(options = {})
      options ||= {}
      self.errors = nil
      fail 'No validation endpoint found!' unless validation_endpoint
      record = LHS::Record.for_url(validation_endpoint.url)
      validation_params = validation_endpoint.options[:validates] == true ? { persist: false } : { validation_endpoint.options[:validates] => false }
      params = validation_endpoint.options.fetch(:params, {})
        .merge(params_from_embeded_href)
        .merge(validation_params)
      begin
        record.request(
          options.merge(
            url: validation_endpoint.url,
            method: :post,
            params: params,
            body: _data.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
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
      endpoint = embeded_endpoint if _data.href # take embeded first
      endpoint ||= _data._record.find_endpoint(_data._raw)
      validates = endpoint.options && endpoint.options.fetch(:validates, false)
      fail 'Endpoint does not support validations!' unless validates
      endpoint
    end

    def embeded_endpoint
      LHS::Endpoint.for_url(_data.href)
    end

    def params_from_embeded_href
      return {} unless _data.href
      LHC::Endpoint.values_as_params(embeded_endpoint.url, _data.href)
    end
  end
end
