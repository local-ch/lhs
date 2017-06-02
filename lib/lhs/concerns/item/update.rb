require 'active_support'
require File.dirname(__FILE__) + '/../../proxy'

class LHS::Item < LHS::Proxy

  module Update
    extend ActiveSupport::Concern

    def update(params, options = nil)
      update!(params, options)
    rescue LHC::Error => e
      self.errors = LHS::Errors::Base.new(e.response)
      false
    end

    def update!(params, options = {})
      options ||= {}
      _data.merge_raw!(LHS::Data.new(params, _data.parent, _data.class))
      response_data = _data.class.request(
        options.merge(
          method: :post,
          url: href,
          body: _data.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      )
      _data.merge_raw!(response_data)
      true
    end
  end
end
