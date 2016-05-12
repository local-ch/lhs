require 'active_support'

class LHS::Record

  module Where
    extend ActiveSupport::Concern

    class WhereChain

      # Instance exec is required for scope chains
      delegated_methods = Object.instance_methods - [:instance_exec]
      delegate(*delegated_methods, to: :resolve)

      def initialize(record, parameters)
        @record = record
        @chain = [parameters].compact
      end

      def where(parameters)
        @chain += [parameters].compact
        self
      end

      # Returns a hash of where conditions
      def where_values_hash
        merged_parameters
      end

      protected

      def method_missing(name, *args, &block)
        scope = @record.scopes[name]
        return instance_exec(*args, &scope) if scope
        resolve.send(name, *args, &block)
      end

      def respond_to_missing?(name, include_all = false)
        @record.scopes[name] ||
          resolve.respond_to?(name, include_all)
      end

      def resolve
        @resolved ||= @record.new(
          @record.request(params: merged_parameters)
        )
      end

      private

      def merged_parameters
        merged_parameters = {}
        @chain.each do |parameter|
          merged_parameters.deep_merge!(parameter)
        end
        merged_parameters
      end
    end

    module ClassMethods
      def where(parameters = nil)
        WhereChain.new(self, parameters)
      end
    end
  end
end
