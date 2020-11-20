# frozen_string_literal: true

require 'active_support'

class LHS::Data

  module Extend
    extend ActiveSupport::Concern

    # Extends already fetched data (self) with additionally
    # fetched data (addition) using the given key
    def extend!(addition, key = nil)
      addition = cast_relation_class_for_extension(addition, key)
      if collection?
        extend_collection!(addition, key)
      elsif _raw.is_a?(Array) || self[key]._raw.is_a?(Array)
        extend_array!(addition, key)
      elsif item?
        extend_item!(addition, key)
      end
    end

    private

    def cast_relation_class_for_extension(addition, key = nil)
      return addition if _record.nil? || key.nil? || _record._relations.nil? || _record._relations[key].nil?
      addition.becomes(_record._relations[key][:record_class_name].constantize, errors: addition.errors, warnings: addition.warnings)
    end

    def extend_collection!(addition, key = nil)
      map do |item|
        item_raw = key ? item._raw[key] : item._raw
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

    def extend_array!(addition, key = nil)
      (key ? self[key] : self).zip(addition) do |item, additional_item|
        item._raw.merge!(additional_item._raw) if additional_item.present?
      end
    end

    def extend_item!(addition, key = nil)
      return if addition.nil?
      if addition.collection?
        extend_item_with_collection!(addition, key)
      else # simple case merges hash into hash
        (key ? _raw[key.to_sym] : _raw).merge!(addition._raw)
      end
    end

    def extend_item_with_collection!(addition, key = nil)
      target = (key ? self[key] : self)
      if target._raw.is_a? Array
        self[key] = addition.map(&:_raw) if key
      else # hash with items
        extend_item_with_hash_containing_items!(target, addition)
      end
    end

    def extend_item_with_hash_containing_items!(target, addition)
      LHS::Collection.nest(input: target._raw, value: [], record: self) # inits the nested collection
      if LHS::Collection.access(input: target._raw, record: self).empty?
        LHS::Collection.nest(
          input: target._raw,
          value: addition.reject { |item| item.nil? },
          record: self
        )
      else
        LHS::Collection.access(input: target._raw, record: self).each_with_index do |item, index|
          item.merge!(addition[index])
        end
      end
    end
  end
end
