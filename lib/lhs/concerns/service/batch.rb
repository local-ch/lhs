require 'active_support'

class LHS::Service

  module Batch
    extend ActiveSupport::Concern

    module ClassMethods

      # Process single entries fetched in batches
      def find_each(options = {})
        find_in_batches(options) do |data|
          data.each do |record|
            item = LHS::Item.new(LHS::Data.new(record, data, self.class))
            yield LHS::Data.new(item, data, self.class)
          end
        end
      end

      # Process batches of entries
      def find_in_batches(options = {})
        fail 'No block given' unless block_given?
        start = options[:start] || 1
        batch_size = options[:batch_size] || 100
        params = options[:params] || {}
        loop do # as suggested by Matz
          data = instance.request(params: params.merge(limit: batch_size, offset: start))
          batch_size = data._raw_['limit']
          left = data._raw_['total'].to_i - data._raw_['offset'].to_i - data._raw_['limit'].to_i
          yield data
          break if left <= 0
          start += batch_size
        end
      end
    end
  end
end
