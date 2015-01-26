require File.join(__dir__, 'proxy.rb')
Dir[File.dirname(__FILE__) + '/concerns/data/*.rb'].each {|file| require file }

# Data provides functionalities to accesses information
class LHS::Data
  include Json

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
    return false unless data._raw_.is_a?(Hash)
    _raw_.merge! data._raw_
  end

  def _root_
    root = self
    root = root._parent_ while root && root._parent_
    root
  end

  def class
    _root_._service_
  end

  protected

  # Use existing mapping to provide data
  # or forward to proxy
  def method_missing(name, *args, &block)
    if root_item? && mapping = _root_._service_.instance.mapping[name]
      mapping.call(self)
    else
      _proxy_.send(name, *args, &block)
    end
  end

  private

  def root_item
    return if self._proxy_.class != LHS::Item
    root = root_item = self
    loop do
      root = root._parent_
      root_item = root if root && root._proxy_.is_a?(LHS::Item)
      if !(root && root._parent_)
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
    _root_ == self
  end

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
