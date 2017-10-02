require 'active_support'

class LHS::Item < LHS::Proxy

  module Update
    extend ActiveSupport::Concern

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
      options ||= {}
      partial_data = LHS::Data.new(params, _data.parent, record)
      _data.merge_raw!(partial_data)
      data_sent = partial_update ? partial_data : _data
      response_data = record.request(
        options.merge(
          method: :post,
          url: href,
          body: data_sent.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      )
      _data.merge_raw!(response_data)
      true
    end
  end
end
