module LHS::Nil
  def method_missing(name, *args, &block)
    nil.extend(LHS::Nil)
  end
end
