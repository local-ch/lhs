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

    def add(attribute, message = :invalid, _options = {})
      self[attribute]
      messages[attribute] << generate_message(attribute, message, options)
    end

    def get(key)
      messages[key]
    end

    def set(key, value)
      messages[key] = value
    end

    delegate :delete, to: :messages

    def [](attribute)
      get(attribute.to_sym) || set(attribute.to_sym, [])
    end

    def []=(attribute, error)
      self[attribute] << error
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
      messages[key].push(value)
    end

    def generate_message(attribute, message, options)
      type = options.delete(:message) if options[:message].is_a?(Symbol)

      if @base.class.respond_to?(:i18n_scope)
        defaults = @base.class.lookup_ancestors.map do |klass|
          [ :"#{@base.class.i18n_scope}.errors.models.#{klass.model_name.i18n_key}.attributes.#{attribute}.#{type}",
            :"#{@base.class.i18n_scope}.errors.models.#{klass.model_name.i18n_key}.#{type}" ]
        end
      else
        defaults = []
      end

      defaults << :"#{@base.class.i18n_scope}.errors.messages.#{type}" if @base.class.respond_to?(:i18n_scope)
      defaults << :"errors.attributes.#{attribute}.#{type}"
      defaults << :"errors.messages.#{type}"

      defaults.compact!
      defaults.flatten!

      key = defaults.shift
      defaults = options.delete(:message) if options[:message]
      value = (attribute != :base ? @base.send(:read_attribute_for_validation, attribute) : nil)

      options = {
        default: defaults,
        model: @base.model_name.human,
        attribute: @base.class.human_attribute_name(attribute),
        value: value,
        object: @base
      }.merge!(options)

      I18n.translate(key, options)
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
