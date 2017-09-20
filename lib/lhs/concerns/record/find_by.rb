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
        raise(LHS::Unprocessable.new, 'Cannot find Record without an ID') if params.any? && params.all? { |_, value| value.blank? }
        options ||= {}
        params = params.dup.merge(limit: 1).merge(options.fetch(:params, {}))
        data = request(options.merge(params: params))
        if data && data._proxy.is_a?(LHS::Collection)
          data.first || raise(LHC::NotFound.new('No item was found.', data._request.response))
        elsif data
          data._record.new(data.unwrap_nested_item)
        end
      end
    end
  end
end
