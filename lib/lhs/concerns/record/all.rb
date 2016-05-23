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
      def all(params = {})
        limit = params[limit_key] || Pagination::DEFAULT_LIMIT
        data = request(params: params.merge(limit_key => limit))
        request_all_the_rest(data, params) if paginated?(data._raw)
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

      def request_all_the_rest(data, params)
        pagination = data._record.pagination(data)
        if pagination.pages_left
          last_data = data
          pagination.pages_left.times do |_index|
            return data if last_data.length.zero?
            pagination = data._record.pagination(last_data)
            response_data = request(
              params: params.merge(
                data._record.limit_key => pagination.limit,
                data._record.pagination_key => pagination.next_offset
              )
            )
            data._raw[items_key].concat all_items_from response_data
            data._raw[limit_key] = response_data._raw[limit_key]
            data._raw[total_key] = response_data._raw[total_key]
            data._raw[pagination_key] = response_data._raw[pagination_key]
            last_data = response_data
          end
        end
      end
    end
  end
end
