require 'active_support'

class LHS::Record

  module ChainableRequest
    extend ActiveSupport::Concern

    # Link: A part of a chain
    class Link
      def initialize(hash = nil)
        @hash = hash
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

    # A sequence of links
    class Chain

      # Instance exec is required for scope chains
      delegated_methods = Object.instance_methods - [:instance_exec]
      delegate(*delegated_methods, to: :resolve)

      def initialize(record_class, link, record = nil)
        @record_class = record_class
        @record = record
        @chain = [link].compact
        binding.pry
        self
      end

      def save!(options = nil)
        options ||= {}
        @record.save!(options.merge(merged_options))
      end

      def save(options = nil)
        options ||= {}
        @record.save(options.merge(merged_options))
      end

      def create(data = {})
        @record_class.create(data, merged_options)
      end

      def create!(data = {})
        @record_class.create!(data, merged_options)
      end

      def where(hash = nil)
        push Parameter.new(hash)
      end

      def options(hash = nil)
        push Option.new(hash)
      end

      def find(args)
        @record_class.find(args, merged_options)
      end

      def find_by(params = {})
        @record_class.find_by(params, merged_options)
      end

      # Returns a hash of where conditions
      def where_values_hash
        merged_parameters
      end

      # Returns a hash of options
      def option_values_hash
        merged_options
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
          @record_class.request(merged_options.merge(params: merged_parameters))
        )
      end

      private

      def push(link)
        @chain += [link].compact
        self
      end

      def merged_parameters
        merge_links @chain.select { |link| link.is_a? Parameter }
      end

      def merged_options
        merge_links @chain.select { |link| link.is_a? Option }
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

    # You can start new option chains for already fetched records (needed for save, update, valid etc.)
    def options(hash = nil)
      Chain.new(self, Option.new(hash))
    end

    module ClassMethods
      def where(hash = nil)
        Chain.new(self, Parameter.new(hash))
      end

      def options(hash = nil)
        Chain.new(self, Option.new(hash))
      end
    end
  end
end
