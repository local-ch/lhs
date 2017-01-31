require 'active_support'

class LHS::Record

  module All
    extend ActiveSupport::Concern

    module ClassMethods
      # Should be an edge case but sometimes all objects from a certain resource
      # are required. In this case we load the first page with the default max limit,
      # compute the amount of left over requests, do all the the left over requests
      # for the following pages and concatenate all the results in order to return
      # all the objects for a given resource.
      def all(options = {})
        options ||= {}
        options[:params] ||= {}
        options[:params] = options[:params].merge(limit_key => options[:params][limit_key] || LHS::Pagination::Base::DEFAULT_LIMIT)
        data = request(options)
        load_and_merge_all_the_rest!(data, options) if paginated?(data._raw)
        data._record.new(LHS::Data.new(data, nil, self))
      end

      private

      def paginated?(raw)
        raw.is_a?(Hash) && raw[total_key] && raw[pagination_key]
      end

      def all_items_from(data)
        if data._raw.is_a?(Array)
          data._raw
        else
          data._raw[items_key]
        end
      end

      # After fetching the first page,
      # we can evaluate if there are further remote objects remaining
      # and after preparing all the requests that have to be made in order to fetch all
      # remote items during this batch, they are fetched in parallel
      def load_and_merge_all_the_rest!(data, options)
        if paginated?(data._raw)
          load_and_merge_paginated_collection!(data, options)
        elsif data.collection? && paginated?(data.first._raw)
          load_and_merge_set_of_paginated_collections!(data, options)
        end
      end

      def load_and_merge_paginated_collection!(data, options)
        pagination = data._record.pagination(data)
        return data if pagination.pages_left.zero?
        record = data._record
        record.request(
          options_for_next_batch(record, pagination, options)
        ).each do |batch_data|
          merge_batch_data_with_parent!(batch_data, data)
        end
      end

      def load_and_merge_set_of_paginated_collections!(data, options)
        options_for_this_batch = []
        options.each_with_index do |_, index|
          record = data[index]._record
          pagination = record.pagination(data[index])
          next if pagination.pages_left.zero?
          options_for_this_batch.push(options_for_next_batch(record, pagination, options[index], data[index]))
        end
        data._record.request(options_for_this_batch.flatten).each do |batch_data|
          merge_batch_data_with_parent!(batch_data, batch_data._request.options[:parent_data])
        end
      end

      def merge_batch_data_with_parent!(batch_data, parent_data)
        parent_data._raw[items_key].concat all_items_from batch_data
        parent_data._raw[limit_key] = batch_data._raw[limit_key]
        parent_data._raw[total_key] = batch_data._raw[total_key]
        parent_data._raw[pagination_key] = batch_data._raw[pagination_key]
      end

      def options_for_next_batch(record, pagination, options, parent_data = nil)
        batch_options = []
        pagination.pages_left.times do |index|
          page_options = {
            params: {
              record.limit_key => pagination.limit,
              record.pagination_key => pagination.next_offset(index + 1)
            }
          }
          page_options[:parent_data] = parent_data if parent_data
          batch_options.push(
            options.deep_dup.deep_merge(page_options)
          )
        end
        batch_options
      end
    end
  end
end
