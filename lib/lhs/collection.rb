require File.join(__dir__, 'proxy.rb')

# A collection is a special type of data
# that contains multiple items
class LHS::Collection < LHS::Proxy

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
    if value.is_a? Hash
      data = LHS::Data.new(value, _data)
      item = LHS::Item.new(data)
      LHS::Data.new(item, _data)
    else
      value
    end
  end

  def respond_to_missing?(name, include_all = false)
    _collection.respond_to?(name, include_all)
  end

  # The internal collection class that includes enumerable
  # and insures to return LHS::Items in case of iterating items
  class Collection
    include Enumerable

    attr_accessor :raw
    delegate :last, :sample, :[], :present?, :blank?, :empty?, to: :raw

    def initialize(raw, parent, record)
      self.raw = raw
      @parent = parent
      @record = record
    end

    def each(&_block)
      raw.each do |item|
        if item.is_a? Hash
          yield LHS::Data.new(item, @parent, @record)
        else
          yield item
        end
      end
    end
  end
end
