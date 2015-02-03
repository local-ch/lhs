require File.join(__dir__, 'proxy.rb')

# A collection is a special type of data
# that contains multiple items
class LHS::Collection < LHS::Proxy

  def total
    _data_._raw_['total']
  end

  def limit
    _data_._raw_['limit']
  end

  def offset
    _data_._raw_['offset']
  end

  def href
    _data_._raw_['href']
  end

  def _collection_
    raw = _data_._raw_ if _data_._raw_.is_a?(Array)
    raw ||= _data_._raw_['items']
    Collection.new(raw, _data_, _data_._service_)
  end

  def _raw_
    _data_._raw_
  end

  protected

  def method_missing(name, *args, &block)
    value = _collection_.send(name, *args, &block)
    if value.is_a? Hash
      data = LHS::Data.new(value, _data_)
      item = LHS::Item.new(data)
      LHS::Data.new(item, _data_)
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
