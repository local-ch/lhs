require 'active_support'

class LHS::Service

  module Find
    extend ActiveSupport::Concern

    module ClassMethods

      # Find a single uniqe record
      def find(args)
        if args.is_a? Hash
          find_with_parameters(args)
        else
          find_by_id(args)
        end
      end

      private

      def find_with_parameters(params)
        url = instance.compute_url!(params)
        data = instance.request(url: url, params: params)
        if data._proxy_.is_a?(LHS::Collection)
          raise LHC::NotFound.new('Requested unique item. Multiple were found.', data._request_.response) if data.count > 1
          data.first
        else
          data
        end
      end

      def find_by_id(id)
        url = instance.compute_url!(id: id)
        instance.request(url: url)
      end
    end
  end
end
