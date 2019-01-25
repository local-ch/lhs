# frozen_string_literal: true

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
        options = options.dup
        start = options.delete(:start) || 1
        batch_size = options.delete(:batch_size) || LHS::Pagination::Base::DEFAULT_LIMIT
        loop do # as suggested by Matz
          options = options.dup
          options[:params] = (options[:params] || {}).merge(limit_key(:parameter) => batch_size, pagination_key(:parameter) => start)
          data = request(options)
          batch_size = data._raw.dig(*limit_key(:body))
          left = data._raw.dig(*total_key).to_i - data._raw.dig(*pagination_key(:body)).to_i - data._raw.dig(*limit_key(:body)).to_i
          yield new(data)
          break if left <= 0
          start += batch_size
        end
      end
    end
  end
end
