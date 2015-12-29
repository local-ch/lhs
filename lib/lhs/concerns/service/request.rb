require 'active_support'

class LHS::Service

  module Request
    extend ActiveSupport::Concern

    def request(options)
      if options.is_a? Array
        multiple_requests(options)
      else
        single_request(options)
      end
    end

    private

    # Convert URLs in options to endpoint templates
    def convert_options_to_endpoints(options)
      if options.is_a?(Array)
        options.map { |option| convert_option_to_endpoints(option) }
      else
        convert_option_to_endpoints(options)
      end
    end

    def convert_option_to_endpoints(option)
      new_options = option.dup
      url = option[:url]
      return unless endpoint = LHS::Endpoint.for_url(url)
      template = endpoint.url
      new_options = new_options.merge(params: LHC::Endpoint.values_as_params(template, url))
      new_options[:url] = template
      new_options
    end

    def extend(data, addition, key)
      if data._proxy.is_a? LHS::Collection
        data.each_with_index do |item, i|
          item = item[i] if item.is_a? LHS::Collection
          item._raw[key.to_sym].merge!(addition[i]._raw)
        end
      elsif data._proxy.is_a? LHS::Item
        data._raw[key.to_sym].merge!(addition._raw)
      end
    end

    def handle_includes(includes, data)
      if includes.is_a? Hash
        includes.each { |_include, sub_includes| handle_include(_include, data, sub_includes) }
      elsif includes.is_a? Array
        includes.each { |_include| handle_includes(_include, data) }
      else
        handle_include(includes, data)
      end
    end

    def handle_include(_include, data, sub_includes = nil)
      return unless data.present?
      options = if data._proxy.is_a? LHS::Collection
        options_for_multiple(data, _include)
      else
        url_option_for(data, _include)
      end
      addition = load_include(options, data, sub_includes)
      extend(data, addition, _include)
    end

    # Load additional resources that are requested with include
    def load_include(options, data, sub_includes)
      service = service_for_options(options) || self
      options = convert_options_to_endpoints(options) if service_for_options(options)
      begin
        service.class.includes(sub_includes).instance.request(options)
      rescue LHC::NotFound
        LHS::Data.new({}, data, service)
      end
    end

    # Merge explicit params nested in 'params' namespace with original hash.
    def merge_explicit_params!(params)
      return true unless params
      explicit_params = params[:params]
      params.delete(:params)
      params.merge!(explicit_params) if explicit_params
    end

    def multiple_requests(options)
      options = options.map { |options| process_options(options) }
      responses = LHC.request(options)
      data = responses.map{ |response| LHS::Data.new(response.body, nil, self.class, response.request) }
      data = LHS::Data.new(data, nil, self.class)
      handle_includes(includes, data) if includes
      data
    end

    def options_for_multiple(data, key)
      data.map do |item|
        url_option_for(item, key)
      end
    end

    # Merge explicit params and take configured endpoints options as base
    def process_options(options)
      options ||= {}
      options = options.dup
      options[:params].deep_symbolize_keys! if options[:params]
      endpoint = find_endpoint(options[:params])
      options = (endpoint.options || {}).merge(options)
      options[:url] = compute_url!(options[:params]) unless options.key?(:url)
      merge_explicit_params!(options[:params])
      options.delete(:params) if options[:params] && options[:params].empty?
      options
    end

    def service_for_options(options)
      services = []
      if options.is_a?(Array)
        options.each do |option|
          next unless service = LHS::Service.for_url(option[:url])
          services.push(service)
        end
        fail 'Found more than one service that could be used to do the request' if services.uniq.count > 1
        services.uniq.first
      else # Hash
        LHS::Service.for_url(options[:url])
      end
    end

    def single_request(options)
      response = LHC.request(process_options(options))
      data = LHS::Data.new(response.body, nil, self.class, response.request)
      handle_includes(includes, data) if includes
      data
    end

    def url_option_for(item, key)
      link = item[key]
      { url: link.href }
    end
  end
end
