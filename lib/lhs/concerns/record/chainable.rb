require 'active_support'

class LHS::Record

  module Chainable
    extend ActiveSupport::Concern

    # You can start new option chains for already fetched records (needed for save, update, valid etc.)
    def options(hash = nil)
      Chain.new(self.class, Option.new(hash), self)
    end

    module ClassMethods
      def where(hash = nil)
        Chain.new(self, Parameter.new(hash))
      end

      def all(hash = nil)
        chain = Chain.new(self, Parameter.new(hash))
        chain._links.push(Option.new(all: true))
        chain
      end

      def options(hash = nil)
        Chain.new(self, Option.new(hash))
      end

      def page(page)
        Chain.new(self, Pagination.new(page: page))
      end

      def per(limit)
        Chain.new(self, Pagination.new(per: limit))
      end

      def limit(argument = nil)
        Chain.new(self, Pagination.new(per: argument))
      end

      def handle(error_class, handler)
        Chain.new(self, ErrorHandling.new(error_class => handler))
      end

      def includes(*args)
        Chain.new(self, Include.new(Chain.unfold(args)))
      end

      def includes_all(*args)
        chain = Chain.new(self, Include.new(Chain.unfold(args)))
        chain.include_all!(args)
        chain
      end

      def references(*args)
        Chain.new(self, Reference.new(Chain.unfold(args)))
      end
    end

    # Link: A part of a chain
    class Link

      attr_reader :data

      def initialize(data = nil)
        @data = data
      end

      def [](parameter)
        @data[parameter]
      end
    end

    # Parameter: Part of the chain that will be forwarded to the endpoint as parameter
    class Parameter < Link
    end

    # Option: Part of the chain that will be used to configure the communication with the endpoint
    class Option < Link
    end

    # Pagination: Part of the chain that will be used to controll pagination
    class Pagination < Link
    end

    # Include: Part of the chain that will be used to include linked resources
    class Include < Link
    end

    # Reference: Part of the chain that will be used to pass options to requests
    # made to include linked resources
    class Reference < Link
    end

    # ErrorHandling: Catch and resolve errors when resolving the chain
    class ErrorHandling < Link
      delegate :call, to: :handler

      def handler
        @data.values.first
      end

      def class
        @data.keys.first
      end
    end

    # A sequence of links
    class Chain

      excluded_methods = []
      # Instance exec is required for scope chains
      excluded_methods += [:instance_exec]
      # Clone is required to have immutable
      excluded_methods += [:clone]
      # We are asked from ruby to not delegate __send__ and object_id
      excluded_methods += [:__send__, :object_id]
      delegated_methods = Object.instance_methods - excluded_methods
      delegate(*delegated_methods, to: :resolve)

      attr_accessor :_links

      def self.unfold(args)
        args.size == 1 ? args[0] : args
      end

      def initialize(record_class, link, record = nil)
        @record_class = record_class
        @record = record
        self._links = [link].compact
      end

      def create(data = {})
        @record_class.create(data, resolved_options)
      end

      def create!(data = {})
        @record_class.create!(data, resolved_options)
      end

      def save!(options = nil)
        options ||= {}
        @record.save!(resolved_options.merge(options))
      end

      def save(options = nil)
        options ||= {}
        @record.save(resolved_options.merge(options))
      end

      def destroy(options = nil)
        options ||= {}
        options = options.respond_to?(:to_h) ? options : { id: options }
        if @record
          @record.destroy(resolved_options.merge(options))
        else
          @record_class.destroy(options, resolved_options)
        end
      end

      def update(data = {}, options = nil)
        options ||= {}
        @record.update(data, resolved_options.merge(options))
      end

      def update!(data = {}, options = nil)
        options ||= {}
        @record.update!(data, resolved_options.merge(options))
      end

      def valid?(options = nil)
        options ||= {}
        @record.valid?(resolved_options.merge(options))
      end
      alias validate valid?

      def where(hash = nil)
        push(Parameter.new(hash))
      end

      def all(hash = nil)
        push([Parameter.new(hash), Option.new(all: true)])
      end

      def options(hash = nil)
        push(Option.new(hash))
      end

      def page(page)
        push(Pagination.new(page: page))
      end

      def per(per)
        push(Pagination.new(per: per))
      end

      def limit(argument = nil)
        return resolve.limit if argument.blank?
        push(Pagination.new(per: argument))
      end

      def handle(error_class, handler)
        push(ErrorHandling.new(error_class => handler))
      end

      def includes(*args)
        push(Include.new(Chain.unfold(args)))
      end

      def includes_all(*args)
        chain = push(Include.new(Chain.unfold(args)))
        chain.include_all!(args)
        chain
      end

      def references(*args)
        push(Reference.new(Chain.unfold(args)))
      end

      def find(*args)
        @record_class.find(*args.push(resolved_options))
      end

      def find_by(params = {})
        @record_class.find_by(params, resolved_options)
      end

      def find_by!(params = {})
        @record_class.find_by!(params, resolved_options)
      end

      def first!
        @record_class.first!(resolved_options)
      end

      # Returns a hash of where conditions
      def where_values_hash
        chain_parameters
      end

      # Returns a hash of options
      def option_values_hash
        chain_options
      end

      # Returns a hash of pagination values
      def pagination_values_hash
        chain_pagination
      end

      # Returns a hash of include conditions
      def includes_values
        chain_includes
      end

      # Returns a hash of reference options
      def references_values
        chain_references
      end

      # Adds additional .references(name_of_linked_resource: { all: true })
      # to all linked resources included with includes_all
      def include_all!(args)
        includes_all_to_references(args).each do |reference|
          _links.push(reference)
        end
      end

      protected

      def method_missing(name, *args, &block)
        scope = @record_class.scopes[name]
        return instance_exec(*args, &scope) if scope
        resolve.send(name, *args, &block)
      end

      def respond_to_missing?(name, include_all = false)
        @record_class.scopes[name] ||
          resolve.respond_to?(name, include_all)
      end

      def resolve
        @resolved ||= @record_class.new(
          @record_class.request(resolved_options)
        )
      end

      def resolved_options
        options = chain_options
        options = options.deep_merge(params: chain_parameters.merge(chain_pagination))
        options = options.merge(error_handler: chain_error_handler) if chain_error_handler.present?
        options = options.merge(including: chain_includes) if chain_includes.present?
        options = options.merge(referencing: chain_references) if chain_references.present?
        options
      end

      private

      # Translates includes_all(resources:) to the internal datastructure
      # references(resource: { all: true })
      def includes_all_to_references(args, parent = nil)
        references = []
        if args.is_a?(Array)
          includes_all_to_references_for_arrays!(references, args, parent)
        elsif args.is_a?(Hash)
          includes_all_to_references_for_hash!(references, args, parent)
        elsif args.is_a?(Symbol)
          includes_all_to_references_for_symbol!(references, args, parent)
        end
        references
      end

      def includes_all_to_references_for_arrays!(references, args, parent)
        args.each do |part|
          references.concat(includes_all_to_references(part, parent))
        end
      end

      def includes_all_to_references_for_hash!(references, args, parent)
        args.each do |key, value|
          parent ||= { all: true }
          references.concat([Reference.new(key => parent)])
          references.concat(includes_all_to_references(value, parent))
        end
      end

      def includes_all_to_references_for_symbol!(references, args, parent)
        if parent.present?
          parent[args] = { all: true }
        else
          references.concat([Reference.new(args => { all: true })])
        end
      end

      def push(link)
        clone = self.clone
        clone._links = _links + [link].flatten.compact
        clone
      end

      def chain_parameters
        merge_links(_links.select { |link| link.is_a? Parameter })
      end

      def chain_options
        merge_links(_links.select { |link| link.is_a? Option })
      end

      def chain_error_handler
        _links.select { |link| link.is_a? ErrorHandling }
      end

      def chain_pagination
        resolve_pagination _links.select { |link| link.is_a? Pagination }
      end

      def chain_includes
        LHS::Complex.reduce(
          _links
            .select { |link| link.is_a?(Include) && link.data.present? }
            .map { |link| link.data }
        )
      end

      def chain_references
        LHS::Complex.reduce(
          _links
            .select { |link| link.is_a?(Reference) && link.data.present? }
            .map { |link| link.data }
        )
      end

      def resolve_pagination(links)
        return {} if links.empty?
        page = 1
        per = LHS::Pagination::Base::DEFAULT_LIMIT
        links.each do |link|
          page = link[:page] if link[:page].present?
          per = link[:per] if link[:per].present?
        end
        pagination = @record_class.pagination_class
        {
          @record_class.pagination_key => pagination.page_to_offset(page, per),
          @record_class.limit_key => per
        }
      end

      def merge_links(links)
        hash = {}
        links.each do |link|
          next if link.data.blank?
          hash.deep_merge!(link.data)
        end
        hash
      end
    end
  end
end
