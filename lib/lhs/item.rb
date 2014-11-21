require File.join(__dir__, 'proxy.rb')
Dir[File.dirname(__FILE__) + '/concerns/item/*.rb'].each {|file| require file }

# An item is a concrete record.
# It can be part of another proxy like collection.
class LHS::Item < LHS::Proxy
  include Destroy
  include Save

  # prevent clashing with attributes of underlying data
  attr_accessor :_data_, :errors

  def initialize(data, errors = nil)
    self._data_ = data
    self.errors = errors
  end

  def _raw_
    _data_._raw_
  end

  protected

  def method_missing(name, *args, &block)
    return set(name, args.try(&:first)) if name.to_s[/=$/]
    name = args.first if name == :[]
    value = _data_._raw_[name.to_s]
    value = _data_._raw_[name.to_sym] if value.nil?
    value.extend(LHS::Nil) if value.nil?
    if value.is_a?(Hash)
      handle_hash(value)
    elsif value.is_a?(Array)
      data = LHS::Data.new(value, _data_)
      collection = LHS::Collection.new(data)
      LHS::Data.new(collection, _data_)
    else
      convert(value)
    end
  end

  private

  def convert(value)
    if value.is_a?(String) && value[/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d*.\d{2}:\d{2}/]
      value = DateTime.parse(value)
    else
      value
    end
  end

  def handle_hash(value)
    if (href = value['href'])
      link = LHS::Link.new(href, LHS::Data.new(value, _data_))
      LHS::Data.new(link, _data_)
    else
      LHS::Data.new(value, _data_)
    end
  end

  def set(name, value)
    key = name.to_s.gsub(/=$/, '')
    _data_._raw_[key] = value
  end
end
