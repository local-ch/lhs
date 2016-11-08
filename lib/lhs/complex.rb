# Complex is the main data structure for includes:
# Can be for example :place, [:place, :customer],
# [{ places: [:customer] }, { places: { customer: :contract }}]
# and so on
class LHS::Complex

  # Merge an array of complex that is created
  # when chaining includes/references and
  # reducing values is required for further handling
  def self.merge(data)
    result = []
    data.flatten.uniq.each do |datum|
      result = merge_first_level!(result, datum)
    end
    reduce!(result)
  end

  def self.reduce!(array)
    array.flatten!
    array.uniq!
    return array.first if array.length == 1
    reduce_symbols!(array)
    return nil if array.blank?
    array
  end
  private_class_method :reduce!

  def self.reduce_symbols!(array)
    array.each do |element|
      if element.is_a?(Symbol)
        array.each do |other_element|
          array.delete(element) if other_element.is_a?(Hash) && other_element.key?(element)
          array.delete(element) if other_element.is_a?(Array) && other_element.include?(element)
        end
      end
    end
  end
  private_class_method :reduce_symbols!

  # Merging the addition into the base array (first level)
  def self.merge_first_level!(base, addition)
    return [addition] if base.empty?
    base.each do |element|
      merge_multi_level!(base, element, addition)
    end
  end
  private_class_method :merge_first_level!

  # Merge nested complex (addition) into
  # an hash or an array (element) of the parent
  def self.merge_multi_level!(parent, element, addition, key = nil)
    return if element == addition
    if addition.is_a?(Symbol) && element.is_a?(Hash)
      merge_symbol_into_hash!(parent, element, addition, key)
    elsif addition.is_a?(Symbol) && element.is_a?(Array)
      merge_symbol_into_array!(parent, element, addition, key)
    elsif addition.is_a?(Symbol) && element.is_a?(Symbol)
      add_symbol_to_parent!(parent, element, addition, key)
    elsif addition.is_a?(Hash) && element.is_a?(Symbol)
      merge_hash_into_symbol!(parent, element, addition, key)
    elsif addition.is_a?(Hash) && element.is_a?(Hash)
      merge_hash_into_hash!(parent, element, addition, key)
    elsif addition.is_a?(Hash) && element.is_a?(Array)
      merge_hash_into_array!(element, addition)
    elsif addition.is_a?(Array) && element.is_a?(Symbol)
      merge_array_into_symbol!(parent, element, addition, key)
    elsif addition.is_a?(Array) && element.is_a?(Hash)
      merge_array_into_hash!(parent, element, addition, key)
    elsif addition.is_a?(Array) && element.is_a?(Array)
      merge_array_into_array!(parent, element, addition, key)
    else
      raise "Can't merge that complex: #{addition} -> #{parent} (#{element})#{key ? " for #{key}" : ''}"
    end
  end
  private_class_method :merge_multi_level!

  def self.merge_symbol_into_hash!(parent, element, addition, key = nil)
    return if element.key?(addition)
    if parent.is_a?(Array)
      parent.push(addition)
      reduce!(parent)
    elsif parent.is_a?(Hash)
      parent[key] = reduce!([element, addition])
    else
      raise "Can't merge that complex: #{addition} -> #{parent} (#{element})#{key ? " for #{key}" : ''}"
    end
  end
  private_class_method :merge_symbol_into_hash!

  def self.merge_symbol_into_array!(_parent, element, addition, key = nil)
    return if element.include?(addition)
    element.push(addition)
    reduce!(element)
  end
  private_class_method :merge_symbol_into_array!

  def self.merge_hash_into_symbol!(parent, element, addition, key = nil)
    parent.delete(element) if addition.key?(element)
    if parent.is_a?(Array)
      merge_hash_into_array!(parent, addition)
    elsif parent.is_a?(Hash)
      if addition.key?(element)
        parent[key] = addition
      else
        parent[key] = reduce!([element, addition])
      end
    else
      raise "Can't merge that complex: #{addition} -> #{parent} (#{element})"
    end
  end
  private_class_method :merge_hash_into_symbol!

  def self.merge_array_into_symbol!(parent, element, addition, key = nil)
    addition.unshift(element)
    reduce!(addition)
    parent[key] = addition
  end
  private_class_method :merge_array_into_symbol!

  def self.merge_hash_into_hash!(parent, element, addition, key = nil)
    addition.keys.each do |key|
      if element[key]
        merge_multi_level!(element, element[key], addition[key], key)
      else
        element[key] = addition[key]
      end
    end
  end
  private_class_method :merge_hash_into_hash!

  def self.merge_array_into_hash!(parent, element, addition, key = nil)
    addition.each do |element_to_add|
      merge_multi_level!(parent, element, element_to_add, key)
    end
  end
  private_class_method :merge_array_into_hash!

  def self.merge_array_into_array!(parent, element, addition, key = nil)
    addition.each do |element_to_add|
      merge_multi_level!(element, element, element_to_add)
    end
  end
  private_class_method :merge_array_into_array!

  def self.merge_hash_into_array!(array, addition)
    array.each do |element|
      next unless element.is_a?(Hash)
      element.keys.each do |key|
        next unless addition.key?(key)
        return merge_multi_level!(element, element[key], addition[key], key)
      end
    end
    array.push(addition)
    reduce!(array)
  end
  private_class_method :merge_hash_into_array!

  def self.add_symbol_to_parent!(parent, element, addition, key = nil)
    if parent.is_a?(Array)
      unless parent.include?(addition)
        parent.push(addition)
        reduce!(parent)
      end
    elsif parent.is_a?(Hash)
      add_symbol_to_hash_parent!(parent, element, addition, key)
    else
      raise "Can't merge that complex: #{addition} -> #{parent} (#{element})"
    end
  end
  private_class_method :add_symbol_to_parent!

  def self.add_symbol_to_hash_parent!(parent, element, addition, key)
    return if parent[key] == addition
    return if parent[key].is_a?(Array) && parent[key].include?(addition)
    parent[key] = reduce!([element, addition])
  end
  private_class_method :add_symbol_to_hash_parent!
end
