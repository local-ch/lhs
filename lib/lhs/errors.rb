# Like ActiveModel::Errors
class LHS::Errors
  include Enumerable

  attr_reader :messages, :message, :raw

  def initialize(response)
    @messages = messages_from_response(response)
    @message = message_from_response(response)
    @raw = response.body
    rescue JSON::ParserError
  end

  def include?(attribute)
    messages[attribute].present?
  end
  alias :has_key? :include?
  alias :key? :include?

  def get(key)
    messages[key]
  end

  def set(key, value)
    messages[key] = value
  end

  def delete(key)
    messages.delete(key)
  end

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

  def values
    messages.values
  end

  def keys
    messages.keys
  end

  def count
    to_a.size
  end

  def empty?
    all? { |k, v| v && v.empty? && !v.is_a?(String) }
  end

  private

  def add_error(messages, key, value)
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
    messages
  end

  def messages_from_response(response)
    return {} if !response.body.is_a?(String) || response.body.length.zero?
    json = JSON.parse(response.body)
    parse_messages(json)
  end

  def message_from_response(response)
    json = JSON.parse(response.body)
    json['message']
  end
end
