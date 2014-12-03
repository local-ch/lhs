require 'active_support'

class LHS::Service

  module FindByAndFirst
    extend ActiveSupport::Concern

    module ClassMethods

      # Use find_by to fetch a single record.
      def find_by(params = {})
        params = params.dup.merge(limit: 1)
        url = instance.compute_url!(params)
        data = instance.request(url: url, params: params)
        if data._proxy_.is_a?(LHS::Collection)
          data.first
        else
          data
        end
        rescue LHC::NotFound
          nil
      end
      alias_method :first, :find_by
    end
  end
end
