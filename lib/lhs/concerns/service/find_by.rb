require 'active_support'

class LHS::Service

  module FindBy
    extend ActiveSupport::Concern

    module ClassMethods

      # Fetch some record by parameters
      def find_by(params = {})
        _find_by(params)
        rescue LHC::NotFound
          nil
      end

      # Raise if no record was found
      def find_by!(params = {})
        _find_by(params)
      end

      private

      def _find_by(params)
        params = params.dup.merge(limit: 1)
        data = instance.request(params: params)
        if data._proxy.is_a?(LHS::Collection)
          data.first || fail(LHC::NotFound.new('No item was found.', data._request.response))
        else
          data
        end
      end
    end
  end
end
