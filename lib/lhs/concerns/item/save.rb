# frozen_string_literal: true

require 'active_support'

class LHS::Item < LHS::Proxy
  autoload :EndpointLookup,
    'lhs/concerns/item/endpoint_lookup'

  module Save
    extend ActiveSupport::Concern

    included do
      include EndpointLookup
    end

    def save(options = nil)
      save!(options)
    rescue LHC::Error
      false
    end

    def save!(options = {})
      options = options.present? ? options.dup : {}
      data = _data._raw.dup
      url = url_for_persistance!(data, options)
      create_and_merge_data!(
        apply_default_creation_options(options, url, data)
      )
    rescue LHC::Error => e
      self.errors = LHS::Problems::Errors.new(e.response, record)
      raise e
    end

    private

    def apply_default_creation_options(options, url, data)
      options = options.merge(method: options.fetch(:method, :post), url: url, body: data)
      options[:headers] ||= {}
      options
    end

    def create_and_merge_data!(options)
      response_data = record.request(options)
      if response_data.present?
        _data.merge_raw!(response_data.unwrap(:item_created_key))
        response_headers = response_data._request.response.headers
      end
      if options.fetch(:followlocation, true) && response_headers && response_headers['Location']
        location_data = record.request(options.merge(url: response_headers['Location'], method: :get, body: nil))
        _data.merge_raw!(location_data.unwrap(:item_created_key))
      end
      true
    end
  end
end
