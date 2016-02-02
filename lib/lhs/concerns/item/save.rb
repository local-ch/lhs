require 'active_support'
require File.dirname(__FILE__) + '/../../proxy'

class LHS::Item < LHS::Proxy

  module Save
    extend ActiveSupport::Concern

    def save
      save!
    rescue LHC::Error => e
      self.errors = LHS::Errors.new(e.response)
      false
    end

    def save!
      record = _data._root._record_class
      data = _data._raw.dup
      url =
        if href.present?
          href
        else
          record.find_endpoint(data).compile(data)
        end
      data = record.request(method: :post, url: url, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
      _data.merge_raw!(data)
      true
    end
  end
end
