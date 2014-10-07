# Data provides functionalities to accesses information
class LHS::Data

  # prevent clashing with attributes of underlying data
  attr_accessor :_proxy_, :_raw_, :_parent_, :_service_, :_request_

  def initialize(input, parent = nil, service = nil, request = nil)
    self._raw_ = raw_from_input(input)
    self._proxy_ = proxy_from_input(input)
    self._service_ = service
    self._parent_ = parent
    self._request_ = request
  end

  # merging data
  # e.g. when loading remote data via link
  def merge!(data)
    _raw_.merge! data._raw_
  end

  def _root_
    root = self
    root = root._parent_ while root && root._parent_
    root
  end

  protected

  def method_missing(name, *args, &block)
    _proxy_.send(name, *args, &block)
  end

  private

  def proxy_from_input(input)
    if input.is_a? LHS::Proxy
      input
    elsif (_raw_.is_a?(Hash) && _raw_['items']) || input.is_a?(Array)
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
