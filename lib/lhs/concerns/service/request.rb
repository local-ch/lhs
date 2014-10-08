require 'active_support'

class LHS::Service

  module Request
    extend ActiveSupport::Concern

    def request(options)
      merge_explicit_params!(options[:params])
      request = LHC::Request.new(options)
      LHS::Data.new(request.response.body , nil, self, request)
    end

    private

    # Merge explicit params nested in 'params' namespace with original hash.
    def merge_explicit_params!(params)
      return true unless params
      explicit_params = params[:params]
      params.delete(:params)
      params.merge!(explicit_params) if explicit_params
    end
  end
end
