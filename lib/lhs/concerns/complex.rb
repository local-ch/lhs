# Complex is the main data structure for includes.
# can be for example :entr
class LHS::Complex

  def self.merge(data)
    result = [] if data.first && !data.first.is_a?(Hash)
    result ||= {}
    data.each do |datum|
      merge_datum(datum, result)
    end
    result
  end

  def self.merge_datum(datum, data)
    incompatible = datum.is_a?(Array) && data.is_a?(Hash) ||
      datum.is_a?(Hash) && data.is_a?(Array)
    raise "Can't merge Hash with Array" if incompatible
    if datum.is_a?(Hash)
      data.deep_merge! datum
    else
      data.push datum
    end
  end
end
