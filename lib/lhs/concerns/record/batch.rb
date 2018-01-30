require 'active_support'

class LHS::Record

  module Batch
    extend ActiveSupport::Concern

    module ClassMethods
      # Process single entries fetched in batches
      def find_each(options = {})
        find_in_batches(options) do |records|
          records.each do |record|
            item = LHS::Item.new(record)
            yield new(LHS::Data.new(item, records._data, self))
          end
        end
      end

      # Process batches of entries
      def find_in_batches(options = {})
        raise 'No block given' unless block_given?
        start = options[:start] || 1
        batch_size = options[:batch_size] || LHS::Pagination::Base::DEFAULT_LIMIT
        params = options[:params] || {}
        loop do # as suggested by Matz
          limit_param_name = limit_key(:parameter).kind_of?(Array) ? limit_key(:parameter).last : limit_key(:parameter)
          pagination_param_name = pagination_key(:parameter).kind_of?(Array) ? pagination_key(:parameter).last : pagination_key(:parameter)

          data = request(params: params.merge(limit_param_name => batch_size, pagination_param_name => start))
          batch_size = data._raw.dig(*limit_key(:parameter))
          left = data._raw.dig(*total_key).to_i - data._raw.dig(*pagination_key(:parameter)).to_i - data._raw.dig(*limit_key(:parameter)).to_i
          yield new(data)
          break if left <= 0
          start += batch_size
        end
      end
    end
  end
end
