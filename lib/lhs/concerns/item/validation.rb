require 'active_support'

class LHS::Item < LHS::Proxy

  module Validation
    extend ActiveSupport::Concern

    def valid?(options = {})
      options ||= {}
      self.errors = nil
      endpoint = validation_endpoint
      raise 'No endpoint found to perform validations! See here: https://github.com/local-ch/lhs#validation' unless endpoint
      record = LHS::Record.for_url(endpoint.url)
      params = merge_validation_params!(endpoint)
      url = validation_url(endpoint)
      run_validation!(record, options, url, params)
      true
    rescue LHC::Error => e
      self.errors = LHS::Errors.new(e.response)
      false
    end
    alias validate valid?

    private

    def validation_url(endpoint)
      url = endpoint.url
      action = endpoint.options[:validates][:path].presence
      url = "#{url}/#{action}" if action.present?
      url
    end

    def merge_validation_params!(endpoint)
      validates_params = endpoint.options[:validates].select { |key, _| key.to_sym != :path }
      params = endpoint.options.fetch(:params, {}).merge(params_from_embeded_href)
      params = params.merge(validates_params) if validates_params.is_a?(Hash)
      params
    end

    def run_validation!(record, options, url, params)
      record.request(
        options.merge(
          url: url,
          method: :post,
          params: params,
          body: _data.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      )
    end

    def validation_endpoint
      endpoint = embeded_endpoint if _data.href # take embeded first
      endpoint ||= _data._record.find_endpoint(_data._raw)
      validates = endpoint.options && endpoint.options.fetch(:validates, false)
      raise 'Endpoint does not support validations!' unless validates
      endpoint
    end

    def embeded_endpoint
      LHS::Endpoint.for_url(_data.href)
    end

    def params_from_embeded_href
      return {} if !_data.href || !embeded_endpoint
      LHC::Endpoint.values_as_params(embeded_endpoint.url, _data.href)
    end
  end
end
