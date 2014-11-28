class LHS::NilMock

  attr_reader :data

  def nil?
    true
  end

  def present?
    false
  end

  def ==(a)
    a == nil
  end

  def equal?(a)
    a == nil
  end

  def blank?
    true
  end

  def duplicable?
    false
  end

  def as_json(options = nil)
    self
  end

  def to_param
    self
  end

  def try(*args)
    self
  end

  def try!(*args)
    self
  end

  def inspect
    'nil'
  end

  def to_a
    []
  end

  def rationalize(args)
    (0+0i)
  end

  def to_c
    (0+0i)
  end

  def to_f
    0.0
  end

  def to_h
    {}
  end

  def to_i
    0
  end

  def to_r
    0/1
  end

  def to_s
    ''
  end

  protected

  def method_missing(name, *args, &block)
    self
  end

  private

  attr_writer :data

end
