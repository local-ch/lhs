require 'active_support'

class LHS::Service

  # An endpoint is an url that leads to a backend resource.
  # A service can contain multiple endpoints.
  # The endpoint that is used to request data is choosen
  # based on the provided parameters.
  module Endpoints
    extend ActiveSupport::Concern

    attr_accessor :endpoints
    mattr_accessor :all

    module ClassMethods

      # Adds the endpoint to the list of endpoints.
      def endpoint(url, options = nil)
        endpoint = LHC::Endpoint.new(url, options)
        instance.sanity_check(endpoint)
        instance.endpoints.push(endpoint)
        LHS::Service::Endpoints.all ||= {}
        LHS::Service::Endpoints.all[url] = instance
      end

      def for_url(url)
        template, service = LHS::Service::Endpoints.all.detect do |template, _service|
          LHC::Endpoint.match?(url, template)
        end
        service
      end
    end

    def initialize
      self.endpoints = []
      super
    end

    # Find an endpoint based on the provided parameters.
    # If no parameters are provided it finds the base endpoint
    # otherwise it finds the endpoint that matches the parameters best.
    def find_endpoint(params = {})
      endpoint = find_best_endpoint(params) if params && params.keys.count > 0
      endpoint ||= find_base_endpoint
      endpoint
    end

    # Prevent clashing endpoints.
    def sanity_check(endpoint)
      placeholders = endpoint.placeholders
      fail 'Clashing endpoints.' if endpoints.any? { |e| e.placeholders.sort == placeholders.sort }
    end

    # Computes the url from params
    # by identifiying endpoint and compiles it if necessary.
    # Id in params is threaded in a special way.
    def compute_url!(params)
      endpoint = find_endpoint(params)
      url = endpoint.compile(params)
      url +=  "/#{params.delete(:id)}" if params && params[:id]
      endpoint.remove_interpolated_params!(params)
      url
    end

    private

    # Finds the best endpoint.
    # The best endpoint is the one where all placeholders are interpolated.
    def find_best_endpoint(params)
      sorted_endpoints.find do |endpoint|
        endpoint.placeholders.all? { |match| endpoint.find_value(match, params) }
      end
    end

    # Sort endpoints by number of placeholders, heighest first
    def sorted_endpoints
      endpoints.sort{|a, b| b.placeholders.count <=> a.placeholders.count }
    end

    # Finds the base endpoint.
    # A base endpoint is the one thats has the least amont of placeholers.
    # There cannot be multiple base endpoints.
    def find_base_endpoint
      endpoints = self.endpoints.group_by do |endpoint|
        endpoint.placeholders.length
      end
      bases = endpoints[endpoints.keys.min]
      fail 'Multiple base endpoints found' if bases.count > 1
      bases.first
    end
  end
end
