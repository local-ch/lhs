require 'active_support'

class LHS::Record

  module Where
    extend ActiveSupport::Concern

    class WhereChain

      delegate *Object.instance_methods, to: :resolve

      def initialize(record, parameters)
        @record = record
        @chain = [parameters].compact
      end

      def where(parameters)
        @chain += [parameters].compact
        self
      end

      protected

      def method_missing(name, *args, &block)
        resolve.send(name, *args, &block)
      end

      def respond_to_missing?(name, include_all = false)
        resolve.respond_to?(name, include_all)
      end

      def resolve
        return @resolved if @resolved
        @resolved = @record.new(
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
