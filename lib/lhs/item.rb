require File.join(__dir__, 'proxy.rb')
Dir[File.dirname(__FILE__) + '/concerns/item/*.rb'].each { |file| require file }

# An item is a concrete record.
# It can be part of another proxy like collection.
class LHS::Item < LHS::Proxy
  include Create
  include Destroy
  include Save
  include Update
  include Validation

  delegate :present?, :blank?, :empty?, to: :_raw
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
