# A data proxy
# to make data from the backend accessible
class LHS::Data

  # prevent clashing with attributes of underlying data
  attr_accessor :_proxy_, :_raw_

  def initialize(input)
    self._raw_ = (input.is_a?(String) && input.length > 0) ? JSON.parse(input) : input
    self._proxy_ = proxy_from_input(input)
  end

  protected

  def method_missing(name, *args, &block)
    _proxy_.send(name, *args, &block)
  end

  private

  def proxy_from_input(input)
    if [LHS::Link, LHS::Item, LHS::Collection].include?(input.class)
      input
    elsif _raw_.is_a?(Hash) && _raw_['items']
      LHS::Collection.new(self)
    else
      LHS::Item.new(self)
    end
  end
end
