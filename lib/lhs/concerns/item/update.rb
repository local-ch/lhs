# frozen_string_literal: true

require 'active_support'

class LHS::Item < LHS::Proxy
  autoload :EndpointLookup,
    'lhs/concerns/item/endpoint_lookup'

  module Update
    extend ActiveSupport::Concern

    included do
      include EndpointLookup
    end

    def update(params, options = nil)
      update!(params, options)
    rescue LHC::Error => e
      self.errors = LHS::Problems::Errors.new(e.response, record)
      false
    end

    def partial_update(params, options = nil)
      update!(params, options, true)
    rescue LHC::Error => e
      self.errors = LHS::Problems::Errors.new(e.response, record)
      false
    end

    def partial_update!(params, options = nil)
      update!(params, options, true)
    end

    def update!(params, options = {}, partial_update = false)
      options = options.present? ? options.dup : {}
      partial_record = _record.new(LHS::Data.new(params, _data.parent, _record))
      _data.merge_raw!(partial_record._data)
      data = _data._raw.dup
      url = url_for_persistance!(data, options)
      data_sent = partial_update ? partial_record._data : data
      response_data = record.request(
        options.merge(
          method: options.fetch(:method, :post),
          url: url,
          body: data_sent
        )
      )
      _data.merge_raw!(response_data.unwrap(:item_created_key))
      true
    end
  end
end
