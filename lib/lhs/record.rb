Dir[File.dirname(__FILE__) + '/concerns/record/*.rb'].each { |file| require file }

class LHS::Record
  include Batch
  include Chainable
  include Configuration
  include Create
  include Destroy
  include Endpoints
  include Equality
  include Find
  include FindBy
  include First
  include Inspect
  include Mapping
  include Model
  include Pagination
  include Request
  include RequestCycleCache
  include Scope

  delegate :_proxy, :_endpoint, :merge_raw!, :select, to: :_data

  def initialize(data = nil, apply_customer_setters = true)
    data = LHS::Data.new({}, nil, self.class) unless data
    data = LHS::Data.new(data, nil, self.class) unless data.is_a?(LHS::Data)
    define_singleton_method(:_data) { data }
    apply_custom_setters! if apply_customer_setters
  end

  def as_json(options = nil)
    _data.as_json(options)
  end

  def self.build(data = nil)
    new(data)
  end

  protected

  def method_missing(name, *args, &block)
    _data.send(name, *args, &block)
  end

  def respond_to_missing?(name, include_all = false)
    _data.respond_to_missing?(name, include_all)
  end

  private

  def apply_custom_setters!
    return if !_data.item? || !_data._raw.respond_to?(:keys)
    raw = _data._raw
    custom_setters = raw.keys.find_all { |key| public_methods.include?("#{key}=".to_sym) }
    custom_setters.each do |setter|
      value = raw.delete(setter)
      send("#{setter}=", value)
    end
  end
end
