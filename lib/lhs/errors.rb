# Like ActiveModel::Errors
class LHS::Errors
  include Enumerable

  attr_reader :messages, :message

  def initialize(response)
    @messages = messages_from_response(response)
    @message = message_from_response(response)
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

  def messages_from_response(response)
    messages = {}
    return messages if !response.body.is_a?(String) || response.body.length.zero?
    json = JSON.parse(response.body)
    return messages unless json['fields']
    json['fields'].each do |field|
      name = field['name'].to_sym
      messages[name] ||= []
      field['details'].each do |detail|
        messages[name].push(detail['code'])
      end
    end
    messages
  end

  def message_from_response(response)
    json = JSON.parse(response.body)
    json['message']
  end
end
