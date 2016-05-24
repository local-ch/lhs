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

      def options(hash = nil)
        Chain.new(self, Option.new(hash))
      end
    end

    # Link: A part of a chain
    class Link
      def initialize(hash = nil)
        @hash = hash
      end

      def [](parameter)
        @hash[parameter]
      end

      def to_hash
        @hash
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

    # A sequence of links
    class Chain

      # Instance exec is required for scope chains
      delegated_methods = Object.instance_methods - [:instance_exec]
      delegate(*delegated_methods, to: :resolve)

      def initialize(record_class, link, record = nil)
        @record_class = record_class
        @record = record
        @chain = [link].compact
      end

      def create(data = {})
        @record_class.create(data, chain_options)
      end

      def create!(data = {})
        @record_class.create!(data, chain_options)
      end

      def save!(options = nil)
        options ||= {}
        @record.save!(chain_options.merge(options))
      end

      def save(options = nil)
        options ||= {}
        @record.save(chain_options.merge(options))
      end

      def destroy(options = nil)
        options ||= {}
        @record.destroy(chain_options.merge(options))
      end

      def update(data = {}, options = nil)
        options ||= {}
        @record.update(data, chain_options.merge(options))
      end

      def update!(data = {}, options = nil)
        options ||= {}
        @record.update!(data, chain_options.merge(options))
      end

      def valid?(options = nil)
        options ||= {}
        @record.valid?(chain_options.merge(options))
      end
      alias validate valid?

      def where(hash = nil)
        push Parameter.new(hash)
      end

      def options(hash = nil)
        push Option.new(hash)
      end

      def page(page)
        push Pagination.new(page: page)
      end

      def per(per)
        push Pagination.new(per: per)
      end

      def find(args)
        @record_class.find(args, chain_options)
      end

      def find_by(params = {})
        @record_class.find_by(params, chain_options)
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
          @record_class.request(
            chain_options
              .merge(params: chain_parameters.merge(chain_pagination))
          )
        )
      end

      private

      def push(link)
        @chain += [link].compact
        self
      end

      def chain_parameters
        merge_links @chain.select { |link| link.is_a? Parameter }
      end

      def chain_options
        merge_links @chain.select { |link| link.is_a? Option }
      end

      def chain_pagination
        resolve_pagination @chain.select { |link| link.is_a? Pagination }
      end

      def resolve_pagination(links)
        return {} if links.empty?
        page = 1
        per = LHS::Pagination::DEFAULT_LIMIT
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
          next if link.to_hash.blank?
          hash.deep_merge!(link.to_hash)
        end
        hash
      end
    end
  end
end
