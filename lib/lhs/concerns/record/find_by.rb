require 'active_support'

class LHS::Record

  module FindBy
    extend ActiveSupport::Concern

    module ClassMethods
      # Fetch some record by parameters
      def find_by(params = {}, options = nil)
        _find_by(params, options)
      rescue LHC::NotFound
        nil
      end

      # Raise if no record was found
      def find_by!(params = {}, options = nil)
        _find_by(params, options)
      end

      private

      def _find_by(params, options = {})
        options ||= {}
        params = params.dup.merge(limit: 1).merge(options.fetch(:params, {}))
        data = request(options.merge(params: params))
        if data && data._proxy.is_a?(LHS::Collection)
          data.first || raise(LHC::NotFound.new('No item was found.', data._request.response))
        elsif data
          data._record.new(data)
        end
      end
    end
  end
end
