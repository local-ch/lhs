# Complex is the main data structure for includes:
# Can be for example :place, [:place, :customer],
# [{ places: [:customer] }, { places: { customer: :contract }}]
# and so on
class LHS::Complex
  attr_reader :data

  def reduce!(data)
    if data.is_a?(LHS::Complex)
      @data = data.data
    elsif data.is_a?(Array) && !data.empty?
      @data = data.inject(LHS::Complex.new.reduce!([])) { |acc, datum| acc.merge!(LHS::Complex.new.reduce!(datum)) }.data
    elsif data.is_a?(Hash) && !data.empty?
      @data = data.map { |k, v| [k, LHS::Complex.new.reduce!(v)] }.to_h
    else
      @data = data
    end

    self
  end

  def self.reduce(data)
    new.reduce!(data).unwrap
  end

  def merge!(other)
    if data.is_a?(Symbol)
      merge_into_symbol!(other)
    elsif data.is_a?(Array)
      merge_into_array!(other)
    elsif data.is_a?(Hash)
      merge_into_hash!(other)
    elsif unwrap != other.unwrap
      raise ArgumentError, "Cannot merge #{unwrap} with #{other.unwrap}"
    end

    self
  end

  def unwrap
    if data.is_a?(Array)
      result = data.map(&:unwrap)
      result.empty? ? nil : result
    elsif data.is_a?(Hash)
      result = data.map { |k, v| [k, v.unwrap] }.to_h
      result.empty? ? nil : result
    else
      data
    end
  end

  def ==(other)
    unwrap == other.unwrap
  end

  private

  def merge_into_array!(other)
    if data.empty?
      @data = other.data
    elsif other.data.is_a?(Symbol)
      merge_symbol_into_array!(other)
    elsif other.data.is_a?(Array)
      merge_array_into_array!(other)
    elsif other.data.is_a?(Hash)
      merge_hash_into_array!(other)
    end
  end

  def merge_symbol_into_array!(other)
    return if data.include?(other)
    data.push(other)
  end

  def merge_array_into_array!(other)
    @data = other.data.inject(self) { |acc, datum| acc.merge!(datum) }.data
  end

  def merge_hash_into_array!(other)
    @data = [].tap do |new_data|
      data.each do |element|
        if element.data.is_a?(Symbol)
          # remove keys that were in the hash
          new_data << element if !other.data.key?(element.data)
        elsif element.data.is_a?(Array)
          new_data << element
        elsif element.data.is_a?(Hash)
          new_data << element.merge!(other)
        end
      end
    end

    # add it to the array if there was no hash to merge it
    data.push(other) if data.none? { |element| element.data.is_a?(Hash) }
  end

  def merge_into_hash!(other)
    if data.empty?
      @data = other.data
    elsif other.data.is_a?(Symbol)
      merge_symbol_into_hash!(other)
    elsif other.data.is_a?(Array)
      merge_array_into_hash!(other)
    elsif other.data.is_a?(Hash)
      merge_hash_into_hash!(other)
    end
  end

  def merge_symbol_into_hash!(other)
    return if data.key?(other.data)

    @data = [LHS::Complex.new.reduce!(data), other]
  end

  def merge_array_into_hash!(other)
    @data = other.data.inject(self) { |acc, datum| acc.merge!(datum) }.data
  end

  def merge_hash_into_hash!(other)
    other.data.each do |k, v|
      if data.key?(k)
        data[k] = data[k].merge!(v)
      else
        data[k] = v
      end
    end
  end

  def merge_into_symbol!(other)
    if other.data.is_a?(Symbol)
      merge_symbol_into_symbol!(other)
    elsif other.data.is_a?(Array)
      merge_array_into_symbol!(other)
    elsif other.data.is_a?(Hash)
      merge_hash_into_symbol!(other)
    end
  end

  def merge_symbol_into_symbol!(other)
    return if other.data == data

    @data = [LHS::Complex.new.reduce!(data), other]
  end

  def merge_array_into_symbol!(other)
    @data = other.data.unshift(LHS::Complex.new.reduce!(data)).uniq { |a| a.unwrap }
  end

  def merge_hash_into_symbol!(other)
    if other.data.key?(data)
      @data = other.data
    else
      @data = [LHS::Complex.new.reduce!(data), other]
    end
  end
end
