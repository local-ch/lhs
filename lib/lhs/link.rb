require File.join(__dir__, 'proxy.rb')

# A link is pointing to a backend resource.
# Sometimes a link contains data already.
class LHS::Link < LHS::Proxy

  # prevent clashing with attributes of underlying data
  attr_accessor :_href_, :_data_, :_loaded_

  def initialize(href, data)
    self._href_ = href
    self._data_ = data
    self._loaded_ = false
  end

  def load!
    return self if _loaded_
    fetch
    self
  end

  def reload!
    fetch
    self
  end

  protected

  def method_missing(name, *args, &block)
    _data_.send(name, args, block)
  end

  private

  def fetch
    service_instance = _data_._root_._service_.instance
    data = service_instance.request(url: _href_, method: :get)
    _data_.merge!(data)
    self._loaded_ = true
  end
end
