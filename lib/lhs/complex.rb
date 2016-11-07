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
    simplify_array!(result)
  end

  def self.simplify_array!(result)
    result = result.flatten.uniq
    return result.first if result.length == 1
    result
  end
  private_class_method :simplify_array!

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
  def self.merge_multi_level!(parent, element, addition)
    if addition.is_a?(Symbol) && element.is_a?(Hash)
      merge_symbol_into_hash!(parent, element, addition)
    elsif addition.is_a?(Symbol) && element.is_a?(Array)
      merge_symbol_into_array!(parent, element, addition)
    elsif addition.is_a?(Symbol) && element.is_a?(Symbol)
      add_symbol_to_parent!(parent, element, addition)
    elsif addition.is_a?(Hash) && element.is_a?(Symbol)
      merge_hash_into_symbol!(parent, element, addition)
    elsif addition.is_a?(Hash) && element.is_a?(Array)
      merge_hash_into_array!(parent, element, addition)
    elsif addition.is_a?(Hash) && element.is_a?(Hash)
      merge_hash_into_hash!(parent, element, addition)
    else
      raise "Can't merge that complex: #{addition} -> #{base}"
    end
  end
  private_class_method :merge_multi_level!

  def self.merge_symbol_into_hash!(parent, element, addition)
    return if element.key?(addition)
    parent.push(addition)
    simplify_array!(parent)
  end
  private_class_method :merge_symbol_into_hash!

  def self.merge_symbol_into_array!(_parent, element, addition)
    return if element.include?(addition)
    element.push(addition)
    simplify_array!(parent)
  end
  private_class_method :merge_symbol_into_array!

  def self.merge_hash_into_symbol!(parent, element, addition)
    parent.delete(element) if addition.key?(element)
    parent.push(addition)
    simplify_array!(parent)
  end
  private_class_method :merge_hash_into_symbol!

  def self.merge_hash_into_hash!(parent, element, addition)
    addition.keys.each do |key|
      if element[key]
        merge_multi_level!(element, element[key], addition[key])
      else
        element[key] = addition[key]
      end
    end
  end
  private_class_method :merge_hash_into_hash!

  def self.add_symbol_to_parent!(parent, element, addition)
    if parent.is_a?(Array)
      unless parent.include?(addition)
        parent.push(addition)
        simplify_array!(parent)
      end
    elsif parent.is_a?(Hash)
      add_symbol_to_hash_parent!(parent, element, addition)
    else
      raise "Can't merge that complex: #{addition} -> #{parent} (#{element})"
    end
  end
  private_class_method :add_symbol_to_parent!

  def self.add_symbol_to_hash_parent!(parent, element, addition)
    parent[parent.keys.first] = simplify_array!([element, addition])
  end
  private_class_method :add_symbol_to_hash_parent!
end
