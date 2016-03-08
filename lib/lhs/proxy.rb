# Proxy makes different kind of data accessible
# If href is present it also alows loading/reloading
class LHS::Proxy

  # prevent clashing with attributes of underlying data
  attr_accessor :_data, :_loaded

  def initialize(data)
    self._data = data
    self._loaded = false
  end

  def load!
    return self if _loaded
    reload!
  end

  def reload!
    fail 'No href found' unless _data.href
    data = _data.class.request(url: _data.href, method: :get)
    _data.merge_raw!(data)
    self._loaded = true
    self
  end

end
