require 'active_support'

class LHS::Service

  module All
    extend ActiveSupport::Concern

    module ClassMethods

      def all(params = {})
        all = []
        data = instance.request(params: params.merge(limit: 100))
        all.concat(data._raw['items'])
        total_left = data._raw['total'] - data.count
        limit = data._raw['limit'] || data.count
        requests = total_left / limit
        requests.times do |i|
          offset = limit * (i+1) + 1
          all.concat instance.request(params: params.merge(limit: limit, offset: offset))._raw['items']
        end
        LHS::Data.new(all, nil, self)
      end
    end
  end
end
