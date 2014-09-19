# A collection is a special type of data
# that contains multiple items
class LHS::Collection

  attr_accessor :data, :collection

  def initialize(data)
    self.data = data
    self.collection = data._raw_['items']
  end

  def total
    data._raw_['total']
  end

  protected

  def method_missing(name, *args, &block)
    value = collection.send(name, *args, &block)
    if value.is_a? Hash
      LHS::Data.new(value, self)
    else
      value
    end
  end
end
