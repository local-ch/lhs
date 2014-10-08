require 'active_support'

class LHS::Service

  module All
    extend ActiveSupport::Concern

    module ClassMethods

      def all(params = {})
        all = []
        url = instance.compute_url!(params)
        data = instance.request(url: url, params: params.merge(limit: 100))
        all.concat(data._raw_['items'])
        total_left = data._raw_['total'] - data.count
        requests = total_left / data._raw_['limit']
        requests.times do |i|
          offset = data._raw_['limit'] * (i+1) + 1
          all.concat instance.request(url: url, params: params.merge(limit: data._raw_['limit'], offset: offset))._raw_['items']
        end
        LHS::Data.new(all, nil, self)
      end
    end
  end
end
