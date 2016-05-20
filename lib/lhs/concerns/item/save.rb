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
      options ||= {}
      record = _data.class
      data = _data._raw.dup
      if href.present?
        url = href
      else
        endpoint = record.find_endpoint(data)
        url = endpoint.compile(data)
        endpoint.remove_interpolated_params!(data)
      end

      data = record.request(options.merge(method: :post, url: url, body: data.to_json, headers: { 'Content-Type' => 'application/json' }))
      _data.merge_raw!(data)
      true
    end
  end
end
