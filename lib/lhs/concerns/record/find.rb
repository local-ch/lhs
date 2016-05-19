require 'active_support'

class LHS::Record

  module Find
    extend ActiveSupport::Concern

    module ClassMethods
      # Find a single uniqe record
      def find(args, options = {})
        data =
          if args.is_a? Hash
            find_with_parameters(args, options)
          else
            find_by_id(args, options)
          end
        return data unless data._record
        data._record.new(data)
      end

      private

      def find_with_parameters(params, options = nil)
        options ||= {}
        data = request(options.merge(params: params))
        if data._proxy.is_a?(LHS::Collection)
          fail LHC::NotFound.new('Requested unique item. Multiple were found.', data._request.response) if data.length > 1
          data.first || fail(LHC::NotFound.new('No item was found.', data._request.response))
        else
          data
        end
      end

      def find_by_id(id, options = nil)
        options ||= {}
        request(options.merge(params: { id: id }))
      end
    end
  end
end
