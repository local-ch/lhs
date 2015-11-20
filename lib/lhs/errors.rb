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

  def parse_old_errors(errors):
    parsed = {}
    errors.each do |field|
      name = field['name'].to_sym
      parsed[name] ||= []
      field['details'].each do |detail|
        parsed[name].push(detail['code'])
      end
    end
    parsed
  end

  def parse_errors(errors):
    parsed = {}
    errors.each do |field|
      name = field['path'][0].to_sym
      parsed[name] ||= []
      parsed[name].push(field['code'])
    end
    parsed
  end

  def messages_from_response(response)
    return {} if !response.body.is_a?(String) || response.body.length.zero?
    json = JSON.parse(response.body)
    if json['fields']
      return parse_old_errors(json['fields'])
    end
    if json['field_errors']
      return parse_old_errors(json['field_errors'])
    end
    {}
  end

  def message_from_response(response)
    json = JSON.parse(response.body)
    json['message']
  end
end
