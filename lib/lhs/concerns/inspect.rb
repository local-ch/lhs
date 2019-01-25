# frozen_string_literal: true

require 'active_support'

module LHS
  module Inspect
    extend ActiveSupport::Concern

    def inspect
      [
        [
          [
            [
              to_s.match('LHS::Data') ? 'Data of ' : nil,
              self.class
            ].join,
            _inspect_id
          ].join(' '),
          _inspect_path
        ].compact.join("\n"),
        pretty_raw
      ].compact.join("\n")
    end

    private

    def _inspect_id
      _root.href || (_root.item? ? _root.id : nil) || object_id
    end

    def _inspect_path
      current = self
      path = []
      _collect_parents_for_inspect!(path, current)
      return if path.blank?
      "> #{path.reverse.join(' > ')}"
    end

    def _collect_parents_for_inspect!(path, current)
      return unless current.parent
      parent_raw = current.parent._raw
      if parent_raw.is_a?(Array)
        parent_raw.each_with_index do |element, index|
          path.push(index) if element == current._raw
        end
      elsif parent_raw.is_a?(Hash)
        parent_raw.each do |key, value|
          path.push(key) if value == current._raw
        end
      end
      _collect_parents_for_inspect!(path, current.parent)
    end

    def pretty_raw
      return if _raw.blank?
      if _raw.is_a?(Array)
        _raw
      else
        _raw.to_a.map do |key, value|
          ":#{key} => " +
            if value.is_a? String
              "\"#{value}\""
            else
              value.to_s
            end
        end
      end.join("\n")
    end
  end
end
