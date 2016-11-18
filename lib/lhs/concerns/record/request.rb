require 'active_support'

class LHS::Record

  module Request
    extend ActiveSupport::Concern

    module ClassMethods
      def request(options)
        options ||= {}
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
          options.map { |request_options| convert_options_to_endpoint(request_options) }
        else
          convert_options_to_endpoint(options)
        end
      end

      def convert_options_to_endpoint(options)
        return unless options.present?
        url = options[:url]
        endpoint = LHS::Endpoint.for_url(url)
        return unless endpoint
        template = endpoint.url
        new_options = options.deep_merge(params: LHC::Endpoint.values_as_params(template, url))
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
          link = item[key.to_sym] if item.present?
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
          extend_base_item_with_hash_of_items!(target, addition)
        end
      end

      def extend_base_item_with_hash_of_items!(target, addition)
        target._raw[items_key] ||= []
        if target._raw[items_key].empty?
          target._raw[items_key] = addition.map(&:_raw)
        else
          target._raw[items_key].each_with_index do |item, index|
            item.merge!(addition[index]) if addition[index].present?
          end
        end
      end

      def handle_includes(includes, data, references = {})
        references ||= {}
        references = [references] if includes.is_a?(Array) && !references.is_a?(Array)
        if includes.is_a? Hash
          includes.each { |included, sub_includes| handle_include(included, data, sub_includes, references[included]) }
        elsif includes.is_a? Array
          includes.each_with_index do |included, index|
            handle_includes(included, data, references[index])
          end
        else
          handle_include(includes, data, nil, references[includes])
        end
      end

      def handle_include(included, data, sub_includes = nil, references = nil)
        return if data.blank? || skip_loading_includes?(data, included)
        options = options_for_data(data, included)
        options = extend_with_references(options, references)
        addition = load_include(options, data, sub_includes)
        extend_raw_data!(data, addition, included)
        expand_addition!(data, included) if no_expanded_data?(addition)
      end

      def options_for_data(data, included = nil)
        return options_for_multiple(data, included) if data.collection?
        return options_for_nested_items(data, included) if included && data[included].collection?
        url_option_for(data, included)
      end

      def expand_addition!(data, included)
        addition = data[included]
        options = options_for_data(addition)
        record = record_for_options(options) || self
        options = convert_options_to_endpoints(options) if record_for_options(options)
        expanded_data = begin
          record.request(options)
        rescue LHC::NotFound
          LHS::Data.new({}, data, record)
        end
        extend_raw_data!(data, expanded_data, included)
      end

      def no_expanded_data?(addition)
        return false if addition.blank?
        if addition.item?
          (addition._raw.keys - [:href]).empty?
        elsif addition.collection?
          addition.all? { |item| item && (item._raw.keys - [:href]).empty? }
        end
      end

      # Extends request options with options provided for this reference
      def extend_with_references(options, references)
        return options unless references
        options ||= {}
        if options.is_a?(Array)
          options.map { |request_options| request_options.merge(references) }
        else
          options.merge(references)
        end
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
          if options.is_a?(Array)
            options.each { |options| options.merge!(including: sub_includes) if sub_includes.present? }
          elsif sub_includes.present?
            options.merge!(including: sub_includes)
          end
          record.request(options)
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
        data = LHC.request(options.compact).map do |response|
          LHS::Data.new(response.body, nil, self, response.request)
        end
        including = LHS::Complex.reduce options.compact.map { |options| options.delete(:including) }.compact
        referencing = LHS::Complex.reduce options.compact.map { |options| options.delete(:referencing) }.compact
        data = restore_with_nils(data, locate_nils(options)) # nil objects in data provide location information for mapping
        data = LHS::Data.new(data, nil, self)
        handle_includes(including, data, referencing) if including.present? && !data.empty?
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

      def options_for_multiple(data, key = nil)
        data.map do |item|
          url_option_for(item, key)
        end
      end

      def options_for_nested_items(data, key = nil)
        data[key].map do |item|
          url_option_for(item)
        end
      end

      # Merge explicit params and take configured endpoints options as base
      def process_options(options, endpoint)
        options[:params].deep_symbolize_keys! if options[:params]
        options[:error_handler] = merge_error_handlers(options[:error_handler]) if options[:error_handler]
        options = (endpoint.options || {}).merge(options)
        options[:url] = compute_url!(options[:params]) unless options.key?(:url)
        merge_explicit_params!(options[:params])
        options.delete(:params) if options[:params] && options[:params].empty?
        options
      end

      # LHC supports only one error handler, merge all error handlers to one
      # and reraise
      def merge_error_handlers(handlers)
        lambda do |response|
          return_data = nil
          error_class = LHC::Error.find(response)
          error = error_class.new(error_class, response)
          handlers = handlers.to_a.select { |error_handler| error.is_a? error_handler.class }
          raise(error) unless handlers.any?
          handlers.each do |handler|
            handlers_return = handler.call(response)
            return_data = handlers_return if handlers_return.present?
          end
          return return_data
        end
      end

      def record_for_options(options)
        records = []
        if options.is_a?(Array)
          options.compact.each do |option|
            record = LHS::Record.for_url(option[:url])
            next unless record
            records.push(record)
          end
          raise 'Found more than one record that could be used to do the request' if records.uniq.count > 1
          records.uniq.first
        else # Hash
          LHS::Record.for_url(options[:url])
        end
      end

      def single_request(options)
        options ||= {}
        including = options.delete(:including)
        referencing = options.delete(:referencing)
        options = options.dup
        endpoint = find_endpoint(options[:params])
        response = LHC.request(process_options(options, endpoint))
        data = LHS::Data.new(response.body, nil, self, response.request, endpoint)
        handle_includes(including, data, referencing) if including
        data
      end

      def url_option_for(item, key = nil)
        link = item && key ? item[key] : item
        return { url: link.href } if link.present? && link.href.present?
      end
    end
  end
end
