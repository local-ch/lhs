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

    def multiple_requests(options)
      options.each do |options|
        merge_explicit_params!(options[:params])
      end
      responses = LHC.request(options)
      data = responses.map{ |response| LHS::Data.new(response.body, nil, self, response.request) }
      data = LHS::Data.new(data, nil, self)
      handle_includes(data) if includes
      data
    end

    def single_request(options)
      merge_explicit_params!(options[:params])
      response = LHC.request(options)
      data = LHS::Data.new(response.body , nil, self, response.request)
      handle_includes(data) if includes
      data
    end

    # Merge explicit params nested in 'params' namespace with original hash.
    def merge_explicit_params!(params)
      return true unless params
      explicit_params = params[:params]
      params.delete(:params)
      params.merge!(explicit_params) if explicit_params
    end

    def handle_includes(data)
      if includes.is_a? Hash
        includes.keys.each { |key| handle_include(data, key) }
      else
        handle_include(data, includes)
      end
    end

    def handle_include(data, key)
      options = if data._proxy_.is_a? LHS::Collection
        include_multiple(data, key)
      else
        include_single(data, key)
      end
      addition = if (further_keys = includes.fetch(key, nil) if includes.is_a? Hash)
        self.class.includes(further_keys).instance.request(options)
      else
        self.class.includes(nil).instance.request(options)
      end
      extend(data, addition, key)
    end

    def extend(data, addition, key)
      if data._proxy_.is_a? LHS::Collection
        data.each_with_index do |item, i|
          item = item[i] if item.is_a? LHS::Collection
          item._raw_[key.to_s].merge!(addition[i]._raw_)
        end
      else
        fail 'not yet implemented'
      end
    end

    def include_multiple(data, key)
      data.map do |item|
        include_single(item, key)
      end
    end

    def include_single(item, key)
      link = item[key]
      { url: link.href }
    end
  end
end
