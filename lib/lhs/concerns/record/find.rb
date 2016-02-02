require 'active_support'

class LHS::Record

  module Find
    extend ActiveSupport::Concern

    module ClassMethods
      # Find a single uniqe record
      def find(args)
        data =
          if args.is_a? Hash
            find_with_parameters(args)
          else
            find_by_id(args)
          end
        data._record_class.new(data)
      end

      private

      def find_with_parameters(params)
        data = request(params: params)
        if data._proxy.is_a?(LHS::Collection)
          fail LHC::NotFound.new('Requested unique item. Multiple were found.', data._request.response) if data.count > 1
          data.first || fail(LHC::NotFound.new('No item was found.', data._request.response))
        else
          data
        end
      end

      def find_by_id(id)
        request(params: { id: id })
      end
    end
  end
end
