# frozen_string_literal: true

require 'active_support'

class LHS::Item < LHS::Proxy
  module EndpointLookup
    extend ActiveSupport::Concern

    def url_for_persistance!(data, options)
      return href if href.present?
      endpoint = endpoint_for_persistance!(data, options)
      endpoint.compile(
        merge_data_with_options(data, options)
      ).tap do
        endpoint.remove_interpolated_params!(data)
        endpoint.remove_interpolated_params!(options.fetch(:params, {}))
        options.merge!(endpoint.options.merge(options)) if endpoint.options
      end
    end

    private

    def endpoint_for_persistance!(data, options)
      record.find_endpoint(merge_data_with_options(data, options))
    end
  end
end
