require 'active_support'

class LHS::Service

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
        all.concat(data._raw[:items])
        total_left = data._raw[:total] - data.count
        limit = data._raw[:limit] || data.count
        if limit > 0
          requests = total_left / limit
          requests.times do |i|
            offset = limit * (i+1) + 1
            all.concat request(params: params.merge(limit: limit, offset: offset))._raw[:items]
          end
        end
        LHS::Data.new(all, nil, self)
      end
    end
  end
end
