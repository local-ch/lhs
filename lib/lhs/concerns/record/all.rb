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
        all = []
        default_max_limit = 100
        data = request(params: params.merge(limit: default_max_limit))
        all.concat(all_items_from(data))
        request_all_the_rest(data, all, params) if data._raw.is_a?(Hash) && data._raw[:total] && data._raw[:limit]
        data._record_class.new(LHS::Data.new(all, nil, self))
      end

      private
      
      def all_items_from(data)
        if data._raw.is_a?(Array)
          data._raw
        else
          data._raw[:items]
        end
      end

      def request_all_the_rest(data, all, params)
        total_left = data._raw[:total] - data.count
        limit = data._raw[:limit] || data.count
        if limit > 0
          requests = total_left / limit
          requests.times do |i|
            offset = limit * (i + 1) + 1
            all.concat request(params: params.merge(limit: limit, offset: offset))._raw[:items]
          end
        end
      end
    end
  end
end
