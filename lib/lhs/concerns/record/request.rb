require 'active_support'

class LHS::Record

  module Request
    extend ActiveSupport::Concern

    module ClassMethods
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
        return unless option.present?
        new_options = option.dup
        url = option[:url]
        endpoint = LHS::Endpoint.for_url(url)
        return unless endpoint
        template = endpoint.url
        new_options = new_options.merge(params: LHC::Endpoint.values_as_params(template, url))
        new_options[:url] = template
        new_options
      end

      # Extends existing raw data with additionaly fetched data
      def extend_raw_data!(data, addition, key)
        return if addition.empty?
        if data.collection?
          extend_base_collection!(data, addition, key)
        elsif data[key]._raw.is_a? Array
          extend_base_array!(data, addition, key)
        elsif data.item?
          extend_base_item!(data, addition, key)
        end
      end

      def extend_base_collection!(data, addition, key)
        data.each_with_index do |item, i|
          item = item[i] if item.is_a? LHS::Collection
          link = item[key.to_sym]
          link.merge_raw!(addition[i]) if link.present?
        end
      end

      def extend_base_array!(data, addition, key)
        data[key].zip(addition) do |item, additional_item|
          item._raw.merge!(additional_item._raw)
        end
      end

      def extend_base_item!(data, addition, key)
        if addition.collection?
          extend_base_item_with_collection!(data, addition, key)
        else # simple case merges hash into hash
          data._raw[key.to_sym].merge!(addition._raw)
        end
      end

      def extend_base_item_with_collection!(data, addition, key)
        target = data[key]
        if target._raw.is_a? Array
          data[key] = addition.map(&:_raw)
        else # hash with items
          target._raw[items_key] = addition.map(&:_raw)
        end
      end

      def handle_includes(includes, data)
        if includes.is_a? Hash
          includes.each { |included, sub_includes| handle_include(included, data, sub_includes) }
        elsif includes.is_a? Array
          includes.each { |included| handle_includes(included, data) }
        else
          handle_include(includes, data)
        end
      end

      def handle_include(included, data, sub_includes = nil)
        return if data.blank? || skip_loading_includes?(data, included)
        options =
          if data.collection?
            options_for_multiple(data, included)
          elsif data[included].collection?
            options_for_nested_items(data, included)
          else
            url_option_for(data, included)
          end
        addition = load_include(options, data, sub_includes)
        extend_raw_data!(data, addition, included)
      end

      def skip_loading_includes?(data, included)
        if data.collection?
          data.to_a.none? { |item| item[included].present? }
        else
          !data._raw.key?(included)
        end
      end

      # Load additional resources that are requested with include
      def load_include(options, data, sub_includes)
        record = record_for_options(options) || self
        options = convert_options_to_endpoints(options) if record_for_options(options)
        begin
          record.includes(sub_includes).request(options)
        rescue LHC::NotFound
          LHS::Data.new({}, data, record)
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
        options = options.map do |option|
          next unless option.present?
          process_options(option, find_endpoint(option[:params]))
        end
        data = LHC.request(options.compact).map { |response| LHS::Data.new(response.body, nil, self, response.request) }
        data = restore_with_nils(data, locate_nils(options)) # nil objects in data provide location information for mapping
        unless data.empty?
          data = LHS::Data.new(data, nil, self)
          handle_includes(including, data) if including
        end
        data
      end

      def locate_nils(array)
        nils = []
        array.each_with_index { |value, index| nils << index if value.nil? }
        nils
      end

      def restore_with_nils(array, nils)
        array = array.dup
        nils.sort.each { |index| array.insert(index, nil) }
        array
      end

      def options_for_multiple(data, key)
        data.map do |item|
          url_option_for(item, key)
        end
      end

      def options_for_nested_items(data, key)
        data[key].map do |item|
          url_option_for(item)
        end
      end

      # Merge explicit params and take configured endpoints options as base
      def process_options(options, endpoint)
        options[:params].deep_symbolize_keys! if options[:params]
        options = (endpoint.options || {}).merge(options)
        options[:url] = compute_url!(options[:params]) unless options.key?(:url)
        merge_explicit_params!(options[:params])
        options.delete(:params) if options[:params] && options[:params].empty?
        options
      end

      def record_for_options(options)
        records = []
        if options.is_a?(Array)
          options.compact.each do |option|
            record = LHS::Record.for_url(option[:url])
            next unless record
            records.push(record)
          end
          fail 'Found more than one record that could be used to do the request' if records.uniq.count > 1
          records.uniq.first
        else # Hash
          LHS::Record.for_url(options[:url])
        end
      end

      def single_request(options)
        options ||= {}
        options = options.dup
        endpoint = find_endpoint(options[:params])
        response = LHC.request(process_options(options, endpoint))
        data = LHS::Data.new(response.body, nil, self, response.request, endpoint)
        handle_includes(including, data) if including
        data
      end

      def url_option_for(item, key = nil)
        link = key ? item[key] : item
        return { url: link.href } if link.present? && link.href.present?
      end
    end
  end
end
