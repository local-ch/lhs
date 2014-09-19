# A data proxy
# to make data from the backend accessible
class LHS::Data

  attr_accessor :collection, :raw

  def initialize(data)
    self.raw = (data.is_a?(String) && data.length > 0) ? JSON.parse(data) : data
    self.collection = raw['items']
  end

  protected

  def method_missing(name, *args, &block)
    proxy_collection(name, *args, &block) if collection
  end

  private

  def proxy_collection(name, *args, &block)
    value = collection.send(name, *args, &block)
    if value.is_a? Hash
      LHS::Data.new(value)
    else
      value
    end
  end

end
