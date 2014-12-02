module LHS::Nil
  def method_missing(name, *args, &block)
    nil
  end
end
