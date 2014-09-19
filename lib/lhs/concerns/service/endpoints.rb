require 'active_support'

class LHS::Service

  # An endpoint is an url that leads to a backend service.
  # It can contain params that have to be injected before the url can be used.
  # An endpoint can look like ':datastore/v2/:campaign_id/feedbacks'
  module Endpoints
    extend ActiveSupport::Concern

    INJECTION = /\:.*?(?=\/)/

    attr_accessor :endpoints

    module ClassMethods

      # Adds the endpoint.
      def endpoint(endpoint)
        instance.sanity_check(endpoint)
        instance.endpoints.push(endpoint)
      end
    end

    def initialize
      self.endpoints = []
    end

    # Injects params into url.
    # It will take the data to inject first from global configuration
    # second from the provided parameters.
    def inject(endpoint, params)
      endpoint.gsub(INJECTION) do |match|
        find_injection(match, params) || fail("Incomplete injection. Unable to inject #{match.gsub(':', '')}.")
      end
    end

    # Find an endpoint based on the provided parameters.
    # If no parameters are provided it finds the base endpoint
    # otherwise it finds the endpoint that matches the parameters best.
    def find_endpoint(params = {})
      endpoint = find_best_endpoint(params) if params.keys.count > 0
      endpoint ||= find_base_endpoint
      endpoint
    end

    # Removes keys from provided params hash
    # when they are used for injecting them in the provided endpoint.
    def remove_injected_params(params, endpoint)
      params = params.dup
      endpoint.scan(INJECTION) do |match|
        match = match.gsub(/^\:/, '')
        params.delete(match.to_sym) if find_injection(match, params)
      end
      params
    end

    # Merge explicit params nested in 'params' namespace with original hash.
    def merge_explicit_params!(params)
      explicit_params = params[:params]
      params.delete(:params)
      params.merge!(explicit_params) if explicit_params
    end

    # Prevent clashing endpoints
    # by raising as soon as you try to add one.
    def sanity_check(endpoint)
      injection = endpoint.scan(INJECTION)
      fail 'Clashing endpoints.' if endpoints.any? { |e| e.scan(INJECTION) == injection }
    end

    private

    # Find an injection either in the global configuration
    # or in the provided params
    def find_injection(match, params)
      match = match.gsub(/^\:/, '')
      LHS::Config[match] || params[match.to_sym]
    end

    # Finds the best endpoint.
    # The best endpoint is the one that gets all parameters injected
    # and doenst has any injections left empty.
    def find_best_endpoint(params)
      endpoints.find do |endpoint|
        injections = endpoint.scan(INJECTION)
        injections.all? { |match| find_injection(match, params) }
      end
    end

    # Finds the base endpoint.
    # A base endpoint is the one thats has the least amont of injected parameters.
    # There cannot be multiple base endpoints,
    # because this one is used when query the service without any params.
    def find_base_endpoint
      endpoints = self.endpoints.group_by do |endpoint|
        endpoint.scan(INJECTION).length
      end
      bases = endpoints[endpoints.keys.min]
      fail 'Multiple base endpoints found' if bases.count > 1
      bases.first
    end
  end
end
