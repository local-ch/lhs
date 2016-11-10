# Like ActiveModel::Errors
class LHS::Errors
  include Enumerable

  attr_reader :messages, :message, :raw

  def initialize(response = nil)
    @messages = messages_from_response(response)
    @message = message_from_response(response)
    @raw = response.body if response
  rescue JSON::ParserError # rubocop:disable Lint/HandleExceptions
  end

  def include?(attribute)
    messages[attribute].present?
  end
  alias has_key? include?
  alias key? include?

  def add(attribute, message = :invalid, _options = {})
    self[attribute]
    messages[attribute] << message
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

  def parse_messages(json)
    messages = {}
    if json['fields']
      json['fields'].each do |field|
        field['details'].each do |detail|
          add_error(messages, field['name'].to_sym, detail['code'])
        end
      end
    end
    if json['field_errors']
      json['field_errors'].each do |field_error|
        add_error(messages, field_error['path'].join('.').to_sym, field_error['code'])
      end
    end
    if messages.empty? && json.present?
      json.each do |key, value|
        add_error(messages, key, value)
      end
    end
    messages
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
