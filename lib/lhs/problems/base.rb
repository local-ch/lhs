# frozen_string_literal: true

require 'active_support/core_ext/module'
require 'active_support/core_ext/hash'

# Like ActiveModel::Errors
module LHS::Problems
  class Base
    include Enumerable

    attr_reader :raw, :messages, :codes, :record

    def include?(attribute)
      messages[attribute].present?
    end
    alias has_key? include?
    alias key? include?

    def add(attribute, message = :invalid, options = {})
      self[attribute]
      messages[attribute] << generate_message(attribute, message, options)
    end

    def get(key)
      messages[key]
    end

    def set(key, message)
      return if message.blank?
      messages[key] = [generate_message(key, message)]
    end

    delegate :delete, to: :messages

    def [](attribute)
      get(attribute.to_sym) || messages[attribute] = []
    end

    def []=(attribute, message)
      self[attribute] << generate_message(attribute, message)
    end

    def each
      if messages.is_a?(Hash)
        messages.each_key do |attribute|
          self[attribute].each { |message| yield attribute, message }
        end
      elsif messages.is_a?(Array)
        messages.each { |message| yield message }
      end
    end

    def size
      values.flatten.size
    end

    def clear
      @raw = nil
      @messages.clear
      @codes.clear
    end

    delegate :values, to: :messages

    delegate :keys, to: :messages

    def count
      to_a.size
    end

    def empty?
      all? { |_k, v| v&.empty? && !v.is_a?(String) }
    end

    private

    def add_error(messages, key, value)
      key = key.to_sym
      codes[key] ||= []
      codes[key].push(value)
      messages[key] ||= []
      messages[key].push(generate_message(key, value))
    end

    def generate_message(attribute, message, _options = {})
      problem_type = self.class.name.demodulize.downcase
      find_translated_message(attribute, message, problem_type) || message
    end

    def find_translated_message(attribute, message, problem_type)
      normalized_attribute = attribute.to_s.underscore.gsub(/\.[\d+\.]/, '')
      normalized_message = message.to_s.underscore
      messages = []
      messages = messages_for_record(normalized_attribute, normalized_message, problem_type) if record
      messages.concat([
        ['lhs', problem_type, 'messages', normalized_message],
        ['lhs', problem_type, 'attributes', normalized_attribute, normalized_message],
        ['lhs', problem_type, 'fallback_message']
      ]).detect do |path|
        key = path.join('.')
        return I18n.translate(key) if I18n.exists?(key)
      end
    end

    def messages_for_record(normalized_attribute, normalized_message, problem_type)
      record_name = record.model_name.name.underscore
      [
        ['lhs', problem_type, 'records', record_name, 'attributes', normalized_attribute, normalized_message],
        ['lhs', problem_type, 'records', record_name, normalized_message]
      ]
    end
  end
end
