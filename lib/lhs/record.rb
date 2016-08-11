Dir[File.dirname(__FILE__) + '/concerns/record/*.rb'].each { |file| require file }

class LHS::Record
  include All
  include Batch
  include Chainable
  include Configuration
  include Create
  include Equality
  include Endpoints
  include Find
  include FindBy
  include First
  include Includes
  include Inspect
  include Mapping
  include Model
  include Pagination
  include Request
  include Scope

  delegate :_proxy, :_endpoint, :merge_raw!, :select, to: :_data

  def initialize(data = nil)
    data = LHS::Data.new({}, nil, self.class) unless data
    data = LHS::Data.new(data, nil, self.class) unless data.is_a?(LHS::Data)
    define_singleton_method(:_data) { data }
    consider_custom_setters!
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

  def consider_custom_setters!
    data = instance_data

    return if !data.is_a?(Hash)

    custom_setters = data.keys.find_all { |k| public_methods.include?("#{k}=".to_sym) }
    custom_setters.each do |setter|
      value = data.delete(setter)
      send("#{setter}=", value)
    end
  end

  def instance_data
    if _data._proxy.is_a?(LHS::Collection) && _data._raw.is_a?(Hash)
      _data._raw.fetch(items_key, [])
    else
      _data._raw
    end
  end
end
