require 'active_support'

class LHS::Record

  module RequestCycleCache
    extend ActiveSupport::Concern

    class Interceptor < LHC::Interceptor

      VERSION = 1

      def before_request(request)
        return unless request.method.to_sym == :get
        request.options = request.options.merge({
          cache: true,
          cache_expires_in: 5.minutes,
          cache_race_condition_ttl: 5.seconds,
          cache_key: cache_key_for(request)
        }.merge(request.options))
      end

      private

      def cache_key_for(request)
        [
          "LHS_REQUEST_CYCLE_CACHE(#{VERSION})",
          LHS::Record::RequestCycleCache::RequestCycleThreadRegistry.request_id,
          [
            request.method.upcase,
            [
              request.url,
              request.params.presence
            ].join('?')
          ].join(' ')
        ].join(':')
      end
    end
  end
end