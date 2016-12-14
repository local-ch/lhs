require 'active_support'
require File.dirname(__FILE__) + '/../../proxy'

class LHS::Item < LHS::Proxy

  module Save
    extend ActiveSupport::Concern

    def save(options = nil)
      save!(options)
    rescue LHC::Error => e
      self.errors = LHS::Errors.new(e.response)
      false
    end

    def save!(options = {})
      options = options.present? ? options.dup : {}
      data = _data._raw.dup
      if href.present?
        url = href
      else
        endpoint = endpoint_for_persistance(data, options)
        url = url_for_persistance(endpoint, data, options)
        endpoint.remove_interpolated_params!(data)
        endpoint.remove_interpolated_params!(options.fetch(:params, {}))
        options.merge!(endpoint.options.merge(options)) if endpoint.options
      end

      options = options.merge(method: :post, url: url, body: data.to_json)
      options[:headers] ||= {}
      options[:headers].merge!('Content-Type' => 'application/json')

      data = record_for_persistance.request(options)
      _data.merge_raw!(data)
      true
    end

    private

    def endpoint_for_persistance(data, options)
      record_for_persistance
        .find_endpoint(merge_data_with_options(data, options))
    end

    def merge_data_with_options(data, options)
      if options && options[:params]
        data.merge(options[:params])
      else
        data
      end
    end

    def record_for_persistance
      _data.class
    end

    def url_for_persistance(endpoint, data, options)
      endpoint.compile(
        merge_data_with_options(data, options)
      )
    end
  end
end
