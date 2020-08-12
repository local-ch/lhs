# frozen_string_literal: true

require 'active_support'

class LHS::Data

  module Extend
    extend ActiveSupport::Concern

    # Extends already fetched data (self) with additionally 
    # fetched data (addition) using the given key
    def extend!(addition, key)
      binding.pry
      if self.collection?
        extend_collection!(addition, key)
      elsif self[key]._raw.is_a? Array
        extend_array!(addition, key)
      elsif self.item?
        extend_item!(addition, key)
      end
    end

    private

    def extend_collection!(addition, key)
      self.map do |item|
        item_raw = item._raw[key]
        item_raw.blank? ? [nil] : item_raw
      end
        .flatten
        .each_with_index do |item, index|
          item_addition = addition[index]
          next if item_addition.nil? || item.nil?
          if item_addition._raw.is_a?(Array)
            item[items_key] ||= []
            item[items_key].concat(item_addition._raw)
          else
            item.merge! item_addition._raw
          end
        end
    end

    def extend_array!(addition, key)
      self[key].zip(addition) do |item, additional_item|
        item._raw.merge!(additional_item._raw) if additional_item.present?
      end
    end

    def extend_item!(addition, key)
      return if addition.nil?
      if addition.collection?
        extend_item_with_collection!(addition, key)
      else # simple case merges hash into hash
        self._raw[key.to_sym].merge!(addition._raw)
      end
    end

    def extend_item_with_collection!(addition, key)
      target = self[key]
      if target._raw.is_a? Array
        self[key] = addition.map(&:_raw)
      else # hash with items
        extend_item_with_hash_containing_items!(target, addition)
      end
    end

    def extend_item_with_hash_containing_items!(target, addition)
      LHS::Collection.nest(input: target._raw, value: [], record: self) # inits the nested collection
      if LHS::Collection.access(input: target._raw, record: self).empty?

        LHS::Collection.nest(input: target._raw, value: addition.compact.map(&:_raw), record: self)
      else
        LHS::Collection.access(input: target._raw, record: self).each_with_index do |item, index|
          item.merge!(addition[index])
        end
      end
    end
  end
end
