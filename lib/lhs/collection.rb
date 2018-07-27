# A collection is a special type of data
# that contains multiple items
class LHS::Collection < LHS::Proxy
  autoload :HandleNested,
    'lhs/concerns/collection/handle_nested'
  autoload :InternalCollection,
    'lhs/concerns/collection/internal_collection'

  include HandleNested
  include InternalCollection
  include Create

  METHOD_NAMES_EXLCUDED_FROM_WRAPPING = %w(to_a to_ary map).freeze

  delegate :select, :length, :size, to: :_collection
  delegate :_record, :_raw, to: :_data
  delegate :limit, :count, :total, :offset, :current_page, :start,
           :next?, :previous?, to: :_pagination

  def _pagination
    _record.pagination(_data)
  end

  def href
    return _data._raw[:href] if _data._raw.is_a? Hash
    nil
  end

  def _collection
    @_collection ||= begin
      raw = _data._raw if _data._raw.is_a?(Array)
      raw ||= _data.access(input: _data._raw, record: _record)
      Collection.new(raw, _data, _record)
    end
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
      access(input: _raw, record: _record)
    end
  end

  protected

  def method_missing(name, *args, &block)
    if _collection.respond_to?(name)
      value = _collection.send(name, *args, &block)
      record = LHS::Record.for_url(value[:href]) if value.is_a?(Hash) && value[:href]
      record ||= _record
      value = enclose_item_in_data(value) if value.is_a?(Hash)
      return value if METHOD_NAMES_EXLCUDED_FROM_WRAPPING.include?(name.to_s)
      wrap_return(value, record, name, args)
    elsif _data._raw.is_a?(Hash)
      get(name, *args)
    end
  end

  def respond_to_missing?(name, _include_all = false)
    # We accept every message that does not belong to set of keywords and is not a setter
    !BLACKLISTED_KEYWORDS.include?(name.to_s) && !name.to_s[/=$/]
  end

  private

  # Encloses accessed collection item
  # by wrapping it in an LHS::Item
  def enclose_item_in_data(value)
    data = LHS::Data.new(value, _data, _record)
    item = LHS::Item.new(data)
    LHS::Data.new(item, _data)
  end
end
