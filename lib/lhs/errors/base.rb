# Like ActiveModel::Errors
module LHS::Errors
  class Base
    include Enumerable

    attr_reader :messages, :message, :raw, :record

    def initialize(response = nil, record = nil)
      @raw = response.body if response
      @record = record
      @messages = messages_from_response(response)
      @message = message_from_response(response)
    rescue JSON::ParserError
      @messages = messages || {}
      @message = 'parse error'
      add_error(@messages, 'body', 'parse error')
    end

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

    def set(key, value)
      messages[key] = generate_message(key, value)
    end

    delegate :delete, to: :messages

    def [](attribute)
      get(attribute.to_sym) || set(attribute.to_sym, [])
    end

    def []=(attribute, error)
      self[attribute] << generate_message(attribute, error)
    end

    def each
      messages.each_key do |attribute|
        self[attribute].each { |error| yield attribute, error }
      end
    end

    def size
      values.flatten.size
    end

    def clear
      @raw = nil
      @messages.clear
    end

    delegate :values, to: :messages

    delegate :keys, to: :messages

    def count
      to_a.size
    end

    def empty?
      all? { |_k, v| v && v.empty? && !v.is_a?(String) }
    end

    private

    def add_error(messages, key, value)
      key = key.to_sym
      messages[key] ||= []
      messages[key].push(generate_message(key, value))
    end

    def generate_message(attribute, message, _options = {})
      find_translated_error_message(attribute, message) || message
    end

    def find_translated_error_message(attribute, message)
      normalized_attribute = attribute.to_s.underscore
      normalized_message = message.to_s.underscore
      messages = []
      messages = messages_for_record(normalized_attribute, normalized_message) if record
      messages.concat([
        ['lhs', 'errors', 'messages', normalized_message],
        ['lhs', 'errors', 'attributes', normalized_attribute, normalized_message],
        ['lhs', 'errors', 'fallback_message']
      ]).detect do |path|
        key = path.join('.')
        return I18n.translate(key) if I18n.exists?(key)
      end
    end

    def messages_for_record(normalized_attribute, normalized_message)
      record_name = record.model_name.name.underscore
      [
        ['lhs', 'errors', 'records', record_name, 'attributes', normalized_attribute, normalized_message],
        ['lhs', 'errors', 'records', record_name, normalized_message]
      ]
    end

    def parse_messages(json)
      messages = {}
      fields_to_errors(json, messages) if json['fields']
      field_errors_to_errors(json, messages) if json['field_errors']
      fallback_errors(json, messages) if messages.empty?
      messages
    end

    def fallback_errors(json, messages)
      if json.present?
        json.each do |key, value|
          add_error(messages, key, value)
        end
      else
        add_error(messages, 'unknown', 'error')
      end
    end

    def field_errors_to_errors(json, messages)
      json['field_errors'].each do |field_error|
        add_error(messages, field_error['path'].join('.').to_sym, field_error['code'])
      end
    end

    def fields_to_errors(json, messages)
      json['fields'].each do |field|
        field['details'].each do |detail|
          add_error(messages, field['name'].to_sym, detail['code'])
        end
      end
    end

    def messages_from_response(response = nil)
      return {} if !response || !response.body.is_a?(String) || response.body.length.zero?
      json = JSON.parse(response.body)
      parse_messages(json)
    end

    def message_from_response(response = nil)
      return unless response
      json = JSON.parse(response.body)
      json['message']
    end
  end
end
