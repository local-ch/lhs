class LHS::Record
  module Chainable

    # Resolving entire chains depending on chain type
    # e.g. where, find, find_by, first etc.
    class Resolver

      def resolve!(chain_type, options, record_class)
        @options = options
        @record_class = record_class
        @result = send(chain_type)
      end

      private

      def where
        response_data = @record_class.request(@options)
        response_data ? @record_class.new(response_data) : nil
      end
    end
  end
end
