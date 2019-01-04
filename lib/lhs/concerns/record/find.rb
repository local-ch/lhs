require 'active_support'

class LHS::Record

  module Find
    extend ActiveSupport::Concern

    module ClassMethods
      # Find a single uniqe record
      def find(*args)
        args, options = process_args(args)
        raise(LHS::Unprocessable.new, 'Cannot find Record without an ID') if args.blank? && !args.is_a?(Array)
        data =
          if args.present? && args.is_a?(Array)
            find_in_parallel(args, options)
          elsif args.is_a? Hash
            find_with_parameters(args, options)
          else
            find_by_id(args, options)
          end
        return nil if data.nil?
        return data if !data._record
        if data.collection?
          data.map { |record| data._record.new(record.unwrap_nested_item) }
        else
          data._record.new(data.unwrap_nested_item)
        end
      end

      private

      def process_args(args)
        if args.length == 1
          args = args.first
        elsif args.length == 2 && args.last.is_a?(Hash)
          options = args.pop if args.last.is_a?(Hash)
          args = args.first
        elsif args.last.is_a?(Hash)
          options = args.pop
        end
        options ||= nil
        [args, options]
      end

      def get_unique_item!(data)
        return if data.nil?
        if data._proxy.is_a?(LHS::Collection)
          raise LHC::NotFound.new('Requested unique item. Multiple were found.', data._request.response) if data.length > 1
          data.first || raise(LHC::NotFound.new('No item was found.', data._request.response))
        else
          data
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
        options ||= {}
        if args.is_a? Hash
          options.merge(params: args)
        elsif href?(args)
          options.merge(url: args)
        elsif args.present?
          options.merge(params: { id: args })
        else
          options
        end
      end

      def href?(str)
        str.is_a?(String) && %r{^https?://}.match(str)
      end
    end
  end
end
