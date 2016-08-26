require File.join(__dir__, 'proxy.rb')
Dir[File.dirname(__FILE__) + '/concerns/item/*.rb'].each { |file| require file }

# An item is a concrete record.
# It can be part of another proxy like collection.
class LHS::Item < LHS::Proxy
  include Destroy
  include Save
  include Update
  include Validation

  delegate :present?, :blank?, :empty?, to: :_raw

  # prevent clashing with attributes of underlying data
  attr_accessor :errors

  delegate :_raw, to: :_data

  def item?
    true
  end

  protected

  def method_missing(name, *args, &_block)
    return set(name, args.try(&:first)) if name.to_s[/=$/]
    name = args.first if name == :[]
    value = _data._raw[name.to_s]
    if value.nil? && _data._raw.present?
      value = _data._raw[name.to_sym]
      value ||= _data._raw[name.to_s.classify.to_sym]
    end
    if value.is_a?(Hash)
      handle_hash(value)
    elsif value.is_a?(Array)
      data = LHS::Data.new(value, _data)
      collection = LHS::Collection.new(data)
      LHS::Data.new(collection, _data)
    else
      convert(value)
    end
  end

  def respond_to_missing?(name, _include_all = false)
    # We accept every message that does not belong to set of keywords
    BLACKLISTED_KEYWORDS.exclude?(name.to_s)
  end

  private

  # FIXME: Extend the set of keywords
  BLACKLISTED_KEYWORDS = %w( new proxy_association )

  def convert(value)
    return value unless value.is_a?(String)
    if date_time?(value)
      Time.zone.parse(value)
    elsif date?(value)
      Date.parse(value)
    else
      value
    end
  end

  def handle_hash(value)
    record = LHS::Record.for_url(value[:href]) if value[:href]
    data = LHS::Data.new(value, _data)
    if record
      record.new(data)
    else
      data
    end
  end

  def set(name, value)
    key = name.to_s.gsub(/=$/, '')
    _data._raw[key.to_sym] = value
  end

  def date?(value)
    value[date_time_regex, :date].presence
  end

  def time?(value)
    value[date_time_regex, :time].presence
  end

  def date_time?(value)
    date?(value) && time?(value)
  end

  def date_time_regex
    /(?<date>\d{4}-\d{2}-\d{2})?(?<time>T\d{2}:\d{2}:\d{2}(\.\d*.\d{2}:\d{2})*)?/
  end
end
