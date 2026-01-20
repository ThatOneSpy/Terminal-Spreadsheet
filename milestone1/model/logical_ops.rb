module Logic
  class And
  attr_reader :left_node, :right_node

  def initialize(left_node, right_node)
    @left_node = left_node
    @right_node = right_node
  end

  def visit(visitor)
    visitor.visit_and(self)
  end
end

class Or
  attr_reader :left_node, :right_node

  def initialize(left_node, right_node)
    @left_node = left_node
    @right_node = right_node
  end

  def visit(visitor)
    visitor.visit_or(self)
  end
end

class Not
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def visit(visitor)
    visitor.visit_not(self)
  end
end
end