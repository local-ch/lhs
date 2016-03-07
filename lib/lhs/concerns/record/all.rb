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
        limit = params[limit_key] || 100
        data = request(params: params.merge(limit_key => limit))
        request_all_the_rest(data, params) if data._raw.is_a?(Hash) && data._raw[total_key]
        data._record.new(LHS::Data.new(data, nil, self))
      end

      private

      def all_items_from(data)
        if data._raw.is_a?(Array)
          data._raw
        else
          data._raw[items_key]
        end
      end

      def request_all_the_rest(data, params)
        total_left = data._raw[total_key] - data.count
        limit = data._raw[limit_key] || data.count
        if limit > 0
          requests = total_left / limit
          requests.times do |i|
            offset = limit * (i + 1) + 1
            data._raw[items_key].concat all_items_from request(
              params: params.merge(
                data._record.limit_key => limit,
                data._record.offset_key => offset
              )
            )
          end
        end
      end
    end
  end
end
