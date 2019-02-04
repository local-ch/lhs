# frozen_string_literal: true

require 'active_support'

class LHS::Item < LHS::Proxy

  module Destroy
    extend ActiveSupport::Concern

    def destroy(options = {})
      options ||= {}
      options = options.merge(method: :delete)
      data = _data._raw.dup
      url = url_for_deletion!(options, data)
      options = options.merge(url: url)
      _data._request = _data.class.request(options)._request
      _data
    end

    private

    def url_for_deletion!(options, data)
      return href if href.present?
      endpoint = endpoint_for_deletion(data, options)
      endpoint.compile(
        merge_data_with_options(data, options)
      ).tap do
        endpoint.remove_interpolated_params!(data)
        endpoint.remove_interpolated_params!(options.fetch(:params, {}))
        options.merge!(endpoint.options.merge(options)) if endpoint.options
      end
    end

    def endpoint_for_deletion(data, options)
      record.find_endpoint(merge_data_with_options(data, options))
    end
  end
end
