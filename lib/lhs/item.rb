# An item is a concrete record.
# It can be part of a collection or another item.
class LHS::Item

  # prevent clashing with attributes of underlying data
  attr_accessor :_data_, :_parent_

  def initialize(data, parent = nil)
    self._data_ = data
    self._parent_ = parent
  end

  protected

  def method_missing(name, *args, &block)
    value = _data_._raw_[name.to_s]
    if value.is_a?(Hash) && (href = value['href'])
      LHS::Data.new(LHS::Link.new(href, value, self))
    else
      value
    end
  end
end
