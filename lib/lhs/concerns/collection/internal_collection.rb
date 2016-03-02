require 'active_support'

class LHS::Collection < LHS::Proxy

  module InternalCollection
    extend ActiveSupport::Concern

    # The internal collection class that includes enumerable
    # and insures to return LHS::Items in case of iterating items
    class Collection
      include Enumerable

      attr_accessor :raw
      delegate :last, :sample, :[], :present?, :blank?, :empty?, to: :raw

      def initialize(raw, parent, record)
        self.raw = raw
        @parent = parent
        @record = record
      end

      def each(&_block)
        raw.each do |item|
          if item.is_a? Hash
            yield cast_item(item)
          else
            yield item
          end
        end
      end

      private

      def cast_item(item)
        data = LHS::Data.new(item, @parent, @record)
        return @record.new(data) if @record
        data
      end
    end
  end
end
