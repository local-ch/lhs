require File.join(__dir__, 'proxy.rb')
Dir[File.dirname(__FILE__) + '/concerns/collection/*.rb'].each { |file| require file }

# A collection is a special type of data
# that contains multiple items
class LHS::Collection < LHS::Proxy
  include InternalCollection
  include Create

  delegate :select, :length, :size, to: :_collection
  delegate :_record, :_raw, to: :_data
  delegate :limit, :count, :total, :offset, :current_page, :start,
           :next?, :previous?, to: :_pagination

  def _pagination
    _record.pagination(_data)
  end

  def href
    return _data._raw[:href] if _data.is_a? Hash
    nil
  end

  def _collection
    raw = _data._raw if _data._raw.is_a?(Array)
    raw ||= _data._raw[items_key]
    Collection.new(raw, _data, _record)
  end

  def collection?
    true
  end

  def item?
    false
  end

  def raw_items
    if _raw.is_a?(Array)
      _raw
    else
      _raw[items_key]
    end
  end

  protected

  def method_missing(name, *args, &block)
    if _collection.respond_to?(name)
      value = _collection.send(name, *args, &block)
      return enclose_in_data(value) if value.is_a? Hash
      value
    elsif _data._raw.is_a?(Hash)
      get(name, *args)
    end
  end

  def respond_to_missing?(name, _include_all = false)
    # We accept every message that does not belong to set of keywords and is not a setter
    BLACKLISTED_KEYWORDS.exclude?(name.to_s) && !name.to_s[/=$/]
  end

  private

  def items_key
    return _record.items_key if _record
    :items
  end

  def enclose_in_data(value)
    data = LHS::Data.new(value, _data)
    item = LHS::Item.new(data)
    LHS::Data.new(item, _data)
  end
end
