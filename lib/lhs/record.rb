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
    set_variables data._raw
  end

  def self.build(data = nil)
    self.new(data)
  end
  # data = LHS::Data.new(data, nil, self)
  # item = LHS::Item.new(data)
  # LHS::Data.new(item, nil, self)

  protected

  def method_missing(name, *args, &block)
    _data.send(name, *args, &block)
  end

  private

  def set_variables(input)
    if input.is_a? Hash
      input.each { |k, v| instance_variable_set("@#{k}", v) }
    elsif input.is_a? Array
      input.each { |item| set_variables(item) }
    end
  end
end
