Dir[File.dirname(__FILE__) + '/concerns/record/*.rb'].each { |file| require file }

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
  include Pagination

  delegate :_proxy, to: :_data

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

    send(:data=, instance_data)
  end

  def as_json(options = nil)
    _data.as_json(options)
  end

  def self.build(data = nil)
    new(data)
  end

  protected

  def method_missing(name, *args, &block)
    _data._proxy.send(name, *args, &block)
  end

  def respond_to_missing?(name, include_all = false)
    _data.respond_to_missing?(name, include_all)
  end

  private

  def data=(instance_data)
    return instance_variable_set('@data', instance_data) if !instance_data.is_a?(Hash)

    instance_variable_set('@data', {})
    instance_data.each do |k, v|
      if public_methods.include?("#{k}=".to_sym)
        send("#{k}=", v)
        @data[k] = send(k)._raw
      else
        @data[k] = v
      end
    end
  end
end
