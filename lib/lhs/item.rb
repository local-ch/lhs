require File.join(__dir__, 'proxy.rb')

# An item is a concrete record.
# It can be part of another proxy like collection.
class LHS::Item < LHS::Proxy

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
    value = _data_._raw_[name.to_s]
    if value.is_a?(Hash)
      handle_hash(value)
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
end
