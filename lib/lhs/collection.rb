require File.join(__dir__, 'proxy.rb')

# A collection is a special type of data
# that contains multiple items
class LHS::Collection < LHS::Proxy

  attr_accessor :_data_

  def initialize(data)
    self._data_ = data
  end

  def total
    _data_._raw_['total']
  end

  def _collection_
    _data_._raw_['items']
  end

  def _raw_
    _data_._raw_
  end

  protected

  def method_missing(name, *args, &block)
    value = _collection_.send(name, *args, &block)
    if value.is_a? Hash
      data = LHS::Data.new(value, _data_)
      item = LHS::Item.new(data)
      LHS::Data.new(item, _data_)
    else
      value
    end
  end
end
