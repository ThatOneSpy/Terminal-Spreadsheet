module Bitwise 
  class BitAnd
  attr_reader :left_node, :right_node

  def initialize(left_node, right_node)
    @left_node = left_node
    @right_node = right_node
  end

  def visit(visitor)
    visitor.visit_bitwise_and(self)
  end
end

class BitOr
  attr_reader :left_node, :right_node

  def initialize(left_node, right_node)
    @left_node = left_node
    @right_node = right_node
  end

  def visit(visitor)
    visitor.visit_bitwise_or(self)
  end
end

class BitXor
  attr_reader :left_node, :right_node

  def initialize(left_node, right_node)
    @left_node = left_node
    @right_node = right_node
  end

  def visit(visitor)
    visitor.visit_bitwise_xor(self)
  end
end

class BitNot
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def visit(visitor)
    visitor.visit_bitwise_not(self)
  end
end

class LeftShift
  attr_reader :left_node, :right_node

  def initialize(left_node, right_node)
    @left_node = left_node
    @right_node = right_node
  end

  def visit(visitor)
    visitor.visit_bitwise_left_shift(self)
  end
end

class RightShift
  attr_reader :left_node, :right_node

  def initialize(left_node, right_node)
    @left_node = left_node
    @right_node = right_node
  end

  def visit(visitor)
    visitor.visit_right_shift(self)
  end
end

end