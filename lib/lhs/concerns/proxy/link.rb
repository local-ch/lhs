require 'active_support'

class LHS::Proxy

  module Link
    extend ActiveSupport::Concern

    private

    def record_from_link
      LHS::Record.for_url(_data.href)
    end

    def endpoint_from_link
      LHS::Endpoint.for_url(_data.href)
    end

    def params_from_link
      return {} if !_data.href || !endpoint_from_link
      LHC::Endpoint.values_as_params(endpoint_from_link.url, _data.href)
    end
  end
end
