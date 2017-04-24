require 'active_support'

class LHS::Record

  module Request
    extend ActiveSupport::Concern

    module ClassMethods
      def request(options)
        options ||= {}
        options = options.deep_dup
        if options.is_a?(Array)
          filter_request_options!(options)
          multiple_requests(options)
        else
          single_request(options)
        end
      end

      private

      def filter_request_options!(options)
        options.each_with_index do |option, index|
          next if !option || !option.key?(:url) || !option[:url].nil?
          options[index] = nil
        end
      end

      # Applies limit to the first request of an all request chain
      # Tries to apply an high value for limit and reacts on the limit
      # returned by the endpoint to make further requests
      def apply_limit!(options)
        options[:params] ||= {}
        options[:params] = options[:params].merge(limit_key => options[:params][limit_key] || LHS::Pagination::Base::DEFAULT_LIMIT)
      end

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
          next if link.blank?
          link.merge_raw!(addition[i]) && next if !link.collection?

          link.each_with_index do |item, j|
            item.merge_raw!(addition[i + j]) if item.present?
          end
        end
      end

      def extend_base_array!(data, addition, key)
        data[key].zip(addition) do |item, additional_item|
          item._raw.merge!(additional_item._raw) if additional_item.present?
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
            item.merge!(addition[index])
          end
        end
      end

      def handle_includes(includes, data, references = {})
        references ||= {}
        if includes.is_a? Hash
          includes.each { |included, sub_includes| handle_include(included, data, sub_includes, references[included]) }
        elsif includes.is_a? Array
          includes.each do |included|
            handle_includes(included, data, references)
          end
        else
          handle_include(includes, data, nil, references[includes])
        end
      end

      def handle_include(included, data, sub_includes = nil, references = nil)
        return if data.blank? || skip_loading_includes?(data, included)
        options = options_for_data(data, included)
        options = extend_with_references(options, references)
        addition = load_include(options, data, sub_includes, references)
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
          options.map { |request_options| request_options.merge(references) if request_options.present? }
        elsif options.present?
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

      # After fetching the first page,
      # we can evaluate if there are further remote objects remaining
      # and after preparing all the requests that have to be made in order to fetch all
      # remote items during this batch, they are fetched in parallel
      def load_and_merge_remaining_objects!(data, options)
        if paginated?(data._raw)
          load_and_merge_paginated_collection!(data, options)
        elsif data.collection? && paginated?(data.first.try(:_raw))
          load_and_merge_set_of_paginated_collections!(data, options)
        end
      end

      def load_and_merge_paginated_collection!(data, options)
        pagination = data._record.pagination(data)
        return data if pagination.pages_left.zero?
        record = data._record
        record.request(
          options_for_next_batch(record, pagination, options)
        ).each do |batch_data|
          merge_batch_data_with_parent!(batch_data, data)
        end
      end

      def load_and_merge_set_of_paginated_collections!(data, options)
        options_for_this_batch = []
        options.each_with_index do |_, index|
          record = data[index]._record
          pagination = record.pagination(data[index])
          next if pagination.pages_left.zero?
          options_for_this_batch.push(options_for_next_batch(record, pagination, options[index], data[index]))
        end
        data._record.request(options_for_this_batch.flatten).each do |batch_data|
          merge_batch_data_with_parent!(batch_data, batch_data._request.options[:parent_data])
        end
      end

      # Load additional resources that are requested with include
      def load_include(options, data, sub_includes, references)
        record = record_for_options(options) || self
        options = convert_options_to_endpoints(options) if record_for_options(options)
        begin
          prepare_options_for_include_request!(options, sub_includes, references)
          if references && references[:all] # include all linked resources
            load_include_all!(options, record, sub_includes, references)
          else # simply request first page/batch
            load_include_simple!(options, record)
          end
        rescue LHC::NotFound
          LHS::Data.new({}, data, record)
        end
      end

      def load_include_all!(options, record, sub_includes, references)
        prepare_options_for_include_all_request!(options)
        data = load_all_included!(record, options)
        references.delete(:all) # for this reference all remote objects have been fetched
        continue_including(data, sub_includes, references)
      end

      def load_include_simple!(options, record)
        data = record.request(options)
        warn "[WARNING] You included `#{options[:url]}`, but this endpoint is paginated. You might want to use `includes_all` instead of `includes` (https://github.com/local-ch/lhs#includes_all-for-paginated-endpoints)." if paginated?(data._raw)
        data
      end

      # Continues loading included resources after one complete batch/level has been fetched
      def continue_including(data, including, referencing)
        handle_includes(including, data, referencing) if including.present? && data.present?
        data
      end

      # Loads all included/linked resources,
      # paginates itself to ensure all records are fetched
      def load_all_included!(record, options)
        data = record.request(options)
        load_and_merge_remaining_objects!(data, options)
        data
      end

      # Checks if given raw is paginated or not
      def paginated?(raw)
        !!(raw.is_a?(Hash) && raw[total_key] && raw[pagination_key])
      end

      def prepare_options_for_include_all_request!(options)
        if options.is_a?(Array)
          options.each do |option|
            prepare_option_for_include_all_request!(option)
          end
        else
          prepare_option_for_include_all_request!(options)
        end
        options
      end

      # When including all resources on one level, don't forward :includes & :references
      # as we have to fetch all resources on this level first, before we continue_including
      def prepare_option_for_include_all_request!(option)
        return option unless option.present?
        option[:params] ||= {}
        option[:params].merge!(limit_key => option.fetch(:params, {}).fetch(limit_key, LHS::Pagination::Base::DEFAULT_LIMIT))
        option.delete(:including)
        option.delete(:referencing)
        option
      end

      def prepare_options_for_include_request!(options, sub_includes, references)
        if options.is_a?(Array)
          options.each { |option| option.merge!(including: sub_includes, referencing: references) if sub_includes.present? }
        elsif sub_includes.present?
          options.merge!(including: sub_includes, referencing: references)
        end
        options || {}
      end

      def merge_batch_data_with_parent!(batch_data, parent_data)
        parent_data._raw[items_key].concat batch_data.raw_items
        parent_data._raw[limit_key] = batch_data._raw[limit_key]
        parent_data._raw[total_key] = batch_data._raw[total_key]
        parent_data._raw[pagination_key] = batch_data._raw[pagination_key]
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
          process_options(option, find_endpoint(option[:params], option.fetch(:url, nil)))
        end
        data = LHC.request(options.compact).map do |response|
          LHS::Data.new(response.body, nil, self, response.request)
        end
        including = LHS::Complex.reduce(options.compact.map { |options| options.delete(:including) }.compact)
        referencing = LHS::Complex.reduce(options.compact.map { |options| options.delete(:referencing) }.compact)
        data = restore_with_nils(data, locate_nils(options)) # nil objects in data provide location information for mapping
        data = LHS::Data.new(data, nil, self)
        handle_includes(including, data, referencing) if including.present? && data.present?
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
        end.flatten
      end

      def options_for_nested_items(data, key = nil)
        data[key].map do |item|
          url_option_for(item)
        end.flatten
      end

      def options_for_next_batch(record, pagination, options, parent_data = nil)
        batch_options = []
        pagination.pages_left.times do |index|
          page_options = {
            params: {
              record.limit_key => pagination.limit,
              record.pagination_key => pagination.next_offset(index + 1)
            }
          }
          page_options[:parent_data] = parent_data if parent_data
          batch_options.push(
            options.deep_dup.deep_merge(page_options)
          )
        end
        batch_options
      end

      # Merge explicit params and take configured endpoints options as base
      def process_options(options, endpoint)
        options = options.deep_dup
        options[:params].deep_symbolize_keys! if options[:params]
        options[:error_handler] = merge_error_handlers(options[:error_handler]) if options[:error_handler]
        options = (endpoint.options || {}).merge(options)
        options[:url] = compute_url!(options[:params]) unless options.key?(:url)
        merge_explicit_params!(options[:params])
        options.delete(:params) if options[:params] && options[:params].empty?
        inject_request_cycle_cache!(options)
        options
      end

      # Injects options into request, that enable the LHS::Record::RequestCycleCache::Interceptor
      def inject_request_cycle_cache!(options)
        interceptors = options[:interceptors] || LHC.config.interceptors
        if interceptors.include?(LHC::Caching)
          # Ensure LHS::RequestCycleCache interceptor is prepend
          interceptors = interceptors.unshift(LHS::Record::RequestCycleCache::Interceptor)
          options[:interceptors] = interceptors
        else
          warn("[WARNING] Can't enable LHS::RequestCycleCache as LHC::Caching interceptor is not enabled/configured (see https://github.com/local-ch/lhc/blob/master/docs/interceptors/caching.md#caching-interceptor)!")
        end
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
        options = options.dup
        including = options.delete(:including)
        referencing = options.delete(:referencing)
        endpoint = find_endpoint(options[:params], options.fetch(:url, nil))
        apply_limit!(options) if options[:all]
        response = LHC.request(process_options(options, endpoint))
        data = LHS::Data.new(response.body, nil, self, response.request, endpoint)
        load_and_merge_remaining_objects!(data, process_options(options, endpoint)) if paginated?(data._raw) && options[:all]
        expand_items(data, options[:expanded]) if data.collection? && options[:expanded]
        handle_includes(including, data, referencing) if including.present? && data.present?
        data
      end

      def expand_items(data, expand_options)
        expand_options = {} unless expand_options.is_a?(Hash)
        options = data.map do |item|
          expand_options.merge(url: item.href)
        end
        expanded_data = request(options)
        data.each_with_index do |item, index|
          item.merge_raw!(expanded_data[index])
        end
      end

      def url_option_for(item, key = nil)
        link = key ? item[key] : item
        return if link.blank?
        return { url: link.href } if !link.collection?

        link.map do |item|
          { url: item.href } if item.present? && item.href.present?
        end.compact
      end
    end
  end
end
