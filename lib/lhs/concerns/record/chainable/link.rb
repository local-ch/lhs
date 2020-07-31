class LHS::Record
  module Chainable

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

      def to_a
        [self.class, handler]
      end
    end

    # IgnoredError: Ignore certain LHC errors when resolving the chain
    class IgnoredError < Link
    end

    # ChainType: Part of the chain that indicates how to request the resolved chain 
    # e.g. where, find, find_by, first etc.
    class ChainType < Link
    end
  end
end
