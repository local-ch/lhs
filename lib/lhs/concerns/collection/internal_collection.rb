# frozen_string_literal: true

require 'active_support'

class LHS::Collection < LHS::Proxy

  module InternalCollection
    extend ActiveSupport::Concern

    # The internal collection class that includes enumerable
    # and insures to return LHS::Items in case of iterating items
    class Collection
      include Enumerable

      attr_accessor :raw
      delegate :length, :size, :first, :last, :sample, :[], :present?, :blank?, :empty?,
               :<<, :push, :insert, to: :raw

      def initialize(raw, parent, record)
        self.raw = raw
        @parent = parent
        @record = record
      end

      def to_ary
        map { |item| item }
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

      def compact
        dup.tap do |collection|
          collection.compact! if collection.raw.present?
        end
      end

      def compact!
        self.raw = raw.map do |item|
          if item.is_a?(LHS::Data) && item._request && !item._request.response.success?
            nil
          else
            cast_item(item)
          end
        end.compact
      end

      private

      def cast_item(item)
        data = LHS::Data.new(item, @parent, @record)
        (record_by_href(item) || @record)&.new(data) || data
      end

      def record_by_href(item)
        return if plain_value?(item) || item[:href].blank?

        LHS::Record.for_url(item[:href])
      end

      def plain_value?(item)
        item.is_a?(String) || item.is_a?(Numeric) || item.is_a?(TrueClass) || item.is_a?(FalseClass)
      end
    end
  end
end
