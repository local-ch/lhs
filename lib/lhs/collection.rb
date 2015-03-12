require File.join(__dir__, 'proxy.rb')

# A collection is a special type of data
# that contains multiple items
class LHS::Collection < LHS::Proxy

  def total
    _data._raw['total']
  end

  def limit
    _data._raw['limit']
  end

  def offset
    _data._raw['offset']
  end

  def href
    _data._raw['href']
  end

  def _collection
    raw = _data._raw if _data._raw.is_a?(Array)
    raw ||= _data._raw['items']
    Collection.new(raw, _data, _data._service)
  end

  def _raw
    _data._raw
  end

  protected

  def method_missing(name, *args, &block)
    value = _collection.send(name, *args, &block)
    if value.is_a? Hash
      data = LHS::Data.new(value, _data)
      item = LHS::Item.new(data)
      LHS::Data.new(item, _data)
    else
      value
    end
  end

  private

  # The internal collection class that includes enumerable
  # and insures to return LHS::Items in case of iterating items
  class Collection
    include Enumerable

    attr_accessor :raw

    def initialize(raw, parent, service)
      self.raw = raw
      @parent = parent
      @service = service
    end

    def each(&block)
      raw.each do |item|
        data = LHS::Data.new(item, @parent, @service)
        yield data
      end
    end

    delegate :sample, to: :raw
    delegate :[], to: :raw
  end
end
