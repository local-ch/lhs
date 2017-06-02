Dir[File.dirname(__FILE__) + '/concerns/proxy/*.rb'].each { |file| require file }

# Proxy makes different kind of data accessible
# If href is present it also alows loading/reloading
class LHS::Proxy
  include Accessors
  include Create
  include Errors
  include Link

  # prevent clashing with attributes of underlying data
  attr_accessor :_data, :_loaded

  def initialize(data)
    self._data = data
    self._loaded = false
  end

  def load!(options = nil)
    return self if _loaded
    reload!(options)
  end

  def reload!(options = nil)
    raise 'No href found' unless _data.href
    options = {} if options.blank?

    data = _data.class.request(options.merge(url: _data.href, method: :get))
    _data.merge_raw!(data)
    self._loaded = true
    self
  end
end
