# A data proxy
# to make data from the backend accessible
class LHS::Data

  # prevent clashing with attributes of underlying data
  attr_accessor :_proxy_, :_raw_

  def initialize(input, parent = nil)
    self._raw_ = (input.is_a?(String) && input.length > 0) ? JSON.parse(input) : input
    self._proxy_ = if _raw_.is_a?(Hash) && _raw_['items']
      LHS::Collection.new(self)
    else
      LHS::Item.new(self, parent)
    end
  end

  protected

  def method_missing(name, *args, &block)
    _proxy_.send(name, *args, &block)
  end

end
