require File.join(__dir__, 'proxy.rb')
Dir[File.dirname(__FILE__) + '/concerns/data/*.rb'].each {|file| require file }

# Data provides functionalities to accesses information
class LHS::Data
  include Json

  # prevent clashing with attributes of underlying data
  attr_accessor :_proxy, :_raw, :_parent, :_service, :_request

  def initialize(input, parent = nil, service = nil, request = nil)
    self._raw = raw_from_input(input)
    self._proxy = proxy_from_input(input)
    self._service = service
    self._parent = parent
    self._request = request
  end

  # merging data
  # e.g. when loading remote data via link
  def merge!(data)
    return false unless data._raw.is_a?(Hash)
    _raw.merge! data._raw
  end

  def _root
    root = self
    root = root._parent while root && root._parent
    root
  end

  def class
    _root._service
  end

  protected

  # Use existing mapping to provide data
  # or forward to proxy
  def method_missing(name, *args, &block)
    if root_item? && mapping = _root._service.instance.mapping[name]
      mapping.call(self)
    else
      _proxy.send(name, *args, &block)
    end
  end

  private

  def root_item
    return if self._proxy.class != LHS::Item
    root = root_item = self
    loop do
      root = root._parent
      root_item = root if root && root._proxy.is_a?(LHS::Item)
      if !(root && root._parent)
        break
      else
      end
    end
    root_item
  end

  def root_item?
    root_item == self
  end

  def root?
    _root == self
  end

  def proxy_from_input(input)
    if input.is_a? LHS::Proxy
      input
    elsif (_raw.is_a?(Hash) && _raw['items']) || input.is_a?(Array)
      LHS::Collection.new(self)
    else
      LHS::Item.new(self)
    end
  end

  def raw_from_input(input)
    if input.is_a?(String) && input.length > 0
      JSON.parse(input)
    elsif defined?(input._raw)
      input._raw
    elsif defined?(input._data)
      input._data._raw
    else
      input
    end
  end
end
