require 'active_support'

class LHS::Record

  module RequestCycleCache
    extend ActiveSupport::Concern

    REQUEST_CYCLE_CACHE_WARNING = "[WARNING] Can't enable LHS::RequestCycleCache as LHC::Caching interceptor is not enabled/configured (see https://github.com/local-ch/lhc/blob/master/docs/interceptors/caching.md#caching-interceptor)!".freeze

    class Interceptor < LHC::Interceptor

      VERSION = 1
      CACHED_METHODS = [:get].freeze

      def before_request(request)
        request.options = request.options.merge({
          cache: true,
          cache_expires_in: 5.minutes,
          cache_race_condition_ttl: 5.seconds,
          cache_key: cache_key_for(request),
          cached_methods: CACHED_METHODS
        }.merge(request.options))
      end

      private

      def cache_key_for(request)
        [
          "LHS_REQUEST_CYCLE_CACHE(v#{VERSION})",
          request.method.upcase,
          [request.url, request.params.presence].compact.join('?'),
          "REQUEST=#{LHS::Record::RequestCycleCache::RequestCycleThreadRegistry.request_id}",
          "HEADERS=#{request.headers.hash}"
        ].join(' ')
      end
    end
  end
end
