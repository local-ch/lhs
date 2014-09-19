# A link is pointing to a backend resource.
# Sometimes a link already contains data.
class LHS::Link

  # prevent clashing with attributes of underlying data
  attr_accessor :_href_, :_data_, :_parent_

  def initialize(href, data, parent)
    self._href_ = href
    self._data_ = data
    self._parent_ = parent
  end

  protected

  def method_missing(name, *args, &block)
  end
end
