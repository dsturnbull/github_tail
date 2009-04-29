class Fixnum
  def minutes
    self * 60
  end
  alias_method :minute, :minutes

  def seconds
    self
  end
  alias_method :second, :seconds
end

def minute
  1.minute
end

def second
  1
end
