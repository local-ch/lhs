require 'active_support'

class LHS::Record

  module Find
    extend ActiveSupport::Concern

    module ClassMethods
      # Find a single uniqe record
      def find(args, options = nil)
        data =
          if args.is_a? Array
            find_in_parallel(args, options)
          elsif args.is_a? Hash
            find_with_parameters(args, options)
          else
            find_by_id(args, options)
          end
        return data if data.is_a?(Array) || !data._record
        data._record.new(data)
      end

      private

      def get_unique_item!(data)
        if data._proxy.is_a?(LHS::Collection)
          fail LHC::NotFound.new('Requested unique item. Multiple were found.', data._request.response) if data.length > 1
          data.first || fail(LHC::NotFound.new('No item was found.', data._request.response))
        end
      end

      def find_with_parameters(args, options = {})
        data = request(request_options(args, options))
        get_unique_item!(data)
      end

      def find_by_id(args, options = {})
        request(request_options(args, options))
      end

      def find_in_parallel(args, options)
        options = args.map { |argument| request_options(argument, options) }
        request(options)
      end

      def request_options(args, options)
        if args.is_a? Hash
          (options || {}).merge(params: args)
        else
          (options || {}).merge(params: { id: args })
        end
      end
    end
  end
end
