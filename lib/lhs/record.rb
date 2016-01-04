Dir[File.dirname(__FILE__) + '/concerns/record/*.rb'].each {|file| require file }

class LHS::Record
  include All
  include Batch
  include Create
  include Endpoints
  include Find
  include FindBy
  include First
  include Mapping
  include Model
  include Includes
  include Request
  include Where

  def initialize(data = nil)
    data = LHS::Data.new({}, nil, self.class) unless data
    data = LHS::Data.new(data, nil, self.class) unless data.is_a?(LHS::Data)
    define_singleton_method(:_data) { data }
    if data._proxy.is_a? LHS::Item
      data._raw.each { |k, v| instance_variable_set("@#{k}", v) }
    elsif data._proxy.is_a? LHS::Collection
      instance_variable_set('@collection', data._collection.raw)
    end
  end

  def self.build(data = nil)
    self.new(data)
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
