# An item is a concrete record.
# It can be part of another proxy like collection.
class LHS::Item < LHS::Proxy
  autoload :Becomes,
    'lhs/concerns/item/becomes'
  autoload :Destroy,
    'lhs/concerns/item/destroy'
  autoload :Save,
    'lhs/concerns/item/save'
  autoload :Update,
    'lhs/concerns/item/update'
  autoload :Validation,
    'lhs/concerns/item/validation'

  include Becomes
  include Create
  include Destroy
  include Save
  include Update
  include Validation

  delegate :present?, :blank?, :empty?, to: :_raw, allow_nil: true
  delegate :_raw, to: :_data

  def collection?
    false
  end

  def item?
    true
  end

  protected

  def method_missing(name, *args, &_block)
    return set(name, args.try(&:first)) if name.to_s[/=$/]
    get(name, *args)
  end

  def respond_to_missing?(name, _include_all = false)
    # We accept every message that does not belong to set of keywords
    BLACKLISTED_KEYWORDS.exclude?(name.to_s)
  end
end
