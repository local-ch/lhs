require File.join(__dir__, 'proxy.rb')
Dir[File.dirname(__FILE__) + '/concerns/collection/*.rb'].each { |file| require file }

# A collection is a special type of data
# that contains multiple items
class LHS::Collection < LHS::Proxy
  include InternalCollection

  delegate :select, to: :_collection

  def total
    _data._raw[:total]
  end

  def limit
    _data._raw[:limit]
  end

  def offset
    _data._raw[:offset]
  end

  def href
    _data._raw[:href]
  end

  def _collection
    raw = _data._raw if _data._raw.is_a?(Array)
    raw ||= _data._raw[:items]
    Collection.new(raw, _data, _data._record_class)
  end

  delegate :_raw, to: :_data

  protected

  def method_missing(name, *args, &block)
    value = _collection.send(name, *args, &block)
    return enclose_in_data(value) if value.is_a? Hash
    value
  end

  def respond_to_missing?(name, include_all = false)
    _collection.respond_to?(name, include_all)
  end

  private

  def enclose_in_data(value)
    data = LHS::Data.new(value, _data)
    item = LHS::Item.new(data)
    LHS::Data.new(item, _data)
  end
end
