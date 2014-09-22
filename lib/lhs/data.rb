# Data provides ways to accesses information
class LHS::Data

  # prevent clashing with attributes of underlying data
  attr_accessor :_proxy_, :_raw_

  def initialize(input)
    self._raw_ = raw_from_input(input)
    self._proxy_ = proxy_from_input(input)
  end

  # merging data
  # e.g. when loading remote data via link
  def merge!(data)
    _raw_.merge! data._raw_
  end

  protected

  def method_missing(name, *args, &block)
    _proxy_.send(name, *args, &block)
  end

  private

  def proxy_from_input(input)
    if input.is_a? LHS::Proxy
      input
    elsif _raw_.is_a?(Hash) && _raw_['items']
      LHS::Collection.new(self)
    else
      LHS::Item.new(self)
    end
  end

  def raw_from_input(input)
    if input.is_a?(String) && input.length > 0
      JSON.parse(input)
    elsif defined?(input._raw_)
      input._raw_
    elsif defined?(input._data_)
      input._data_._raw_
    else
      input
    end
  end
end
