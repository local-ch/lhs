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
        requests = total_left / data._raw['limit']
        requests.times do |i|
          offset = data._raw['limit'] * (i+1) + 1
          all.concat instance.request(params: params.merge(limit: data._raw['limit'], offset: offset))._raw['items']
        end
        LHS::Data.new(all, nil, self)
      end
    end
  end
end
