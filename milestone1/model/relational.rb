module Relational 
  class Equals
  attr_reader :left_node, :right_node

  def initialize(left_node, right_node)
    @left_node = left_node
    @right_node = right_node
  end

  def visit(visitor)
    visitor.visit_equals(self)
  end
end

class NotEquals
  attr_reader :left_node, :right_node

  def initialize(left_node, right_node)
    @left_node = left_node
    @right_node = right_node
  end

  def visit(visitor)
    visitor.visit_not_equals(self)
  end
end

class LessThan
  attr_reader :left_node, :right_node

  def initialize(left_node, right_node)
    @left_node = left_node
    @right_node = right_node
  end

  def visit(visitor)
    visitor.visit_less_than(self)
  end
end

class LessThanEqual
  attr_reader :left_node, :right_node

  def initialize(left_node, right_node)
    @left_node = left_node
    @right_node = right_node
  end

  def visit(visitor)
    visitor.visit_less_than_equal(self)
  end
end

class GreaterThan
  attr_reader :left_node, :right_node

  def initialize(left_node, right_node)
    @left_node = left_node
    @right_node = right_node
  end

  def visit(visitor)
    visitor.visit_greater_than(self)
  end
end

class GreaterThanEqual
  attr_reader :left_node, :right_node

  def initialize(left_node, right_node)
    @left_node = left_node
    @right_node = right_node
  end

  def visit(visitor)
    visitor.visit_greater_than_equal(self)
  end
end
end