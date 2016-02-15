Dir[File.dirname(__FILE__) + '/concerns/record/*.rb'].each { |file| require file }

class LHS::Record
  include All
  include Batch
  include Create
  include Endpoints
  include Find
  include FindBy
  include First
  include JSON
  include Mapping
  include Model
  include Includes
  include Request
  include Where

  def initialize(data = nil)
    data = LHS::Data.new({}, nil, self.class) unless data
    data = LHS::Data.new(data, nil, self.class) unless data.is_a?(LHS::Data)
    define_singleton_method(:_data) { data }
    instance_data =
      if data._proxy.is_a?(LHS::Item) && data._raw.is_a?(Hash)
        data._raw
      elsif data._proxy.is_a?(LHS::Collection) && data._raw.is_a?(Hash)
        data._raw.fetch(:items, [])
      else
        data._raw
      end
    instance_variable_set('@data', instance_data)
  end

  def self.build(data = nil)
    new(data)
  end

  protected

  def method_missing(name, *args, &block)
    _data.send(name, *args, &block)
  end

  def respond_to_missing?(name, include_all = false)
    (_data.root_item? && _data._root._record_class.instance_methods.include?(name)) ||
      _data._proxy.respond_to?(name, include_all)
  end
end
