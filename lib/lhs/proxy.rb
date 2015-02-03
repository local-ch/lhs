# Proxy makes different kind of data accessible
# If href is present it also alows loading/reloading
class LHS::Proxy

  # prevent clashing with attributes of underlying data
  attr_accessor :_href_, :_data_, :_loaded_

  def initialize(data)
    self._data_ = data
    self._loaded_ = false
  end

  def load!
    return self if _loaded_
    reload!
  end

  def reload!
    return false unless
    fetch
    self
  end

  private

  def fetch
    service = _data_._root_._service_
    data = service.instance.request(url: _data_.href, method: :get)
    _data_.merge!(data)
    self._loaded_ = true
  end

end
