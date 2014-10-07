require 'active_support'

class LHS::Service

  module Request
    extend ActiveSupport::Concern

    def request(params = {})
      params = params.dup
      url = url_or_endpoint(params)
      merge_explicit_params!(params)
      method = params.delete(:method) || :get
      request = LHC::Request.new(
        url: url,
        method: method,
        params: params
      )
      LHS::Data.new(request.data, nil, self, request)
    end

    private

    # Take url if provided
    # else generate url from found endpoint and injected params
    def url_or_endpoint(params)
      if params[:url]
        url = params.delete(:url)
      else
        endpoint = find_endpoint(params)
        url = inject(endpoint, params)
        url +=  "/#{params.delete(:id)}" if params[:id]
        remove_injected_params!(params, endpoint)
      end
      url
    end
  end
end
