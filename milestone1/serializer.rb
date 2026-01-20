# convert to string representations
class Serializer
  # PRIMITIVES
  def visit_integer(node)
    node.raw_value.to_s
  end

  def visit_float(node)
    node.raw_value.to_s
  end

  def visit_boolean(node)
    node.raw_value.to_s
  end

  def visit_string(node)
    node.raw_value.to_s
  end

  def visit_cell_address(node)
    "[#{node.row}, #{node.col}]"
  end

  #ARITHMETIC
  def visit_add(node)
    "(#{node.left_node.visit(self)} + #{node.right_node.visit(self)})"
  end

  def visit_subtract(node)
    "(#{node.left_node.visit(self)} - #{node.right_node.visit(self)})"
  end

  def visit_multiply(node)
    "(#{node.left_node.visit(self)} * #{node.right_node.visit(self)})"
  end

  def visit_divide(node)
    "(#{node.left_node.visit(self)} / #{node.right_node.visit(self)})"
  end

  def visit_modulo(node)
    "(#{node.left_node.visit(self)} % #{node.right_node.visit(self)})"
  end

  def visit_power(node)
    "(#{node.left_node.visit(self)} ** #{node.right_node.visit(self)})"
  end

  def visit_negation(node)
    negate = node.value.visit(self)
    "-#{negate}"
  end
  
  def visit_exponent(node)
    "(#{node.left_node.visit(self)} ** #{node.right_node.visit(self)})"
  end


  #LOGICAL OPS
  def visit_and(node)
    "(#{node.left_node.visit(self)} && #{node.right_node.visit(self)})"
  end

  def visit_or(node)
    "(#{node.left_node.visit(self)} || #{node.right_node.visit(self)})"
  end

  def visit_not(node)
    negate = node.node.visit(self)
    "!#{negate}"
  end

  #CELL VALS
  def visit_cell_left(node)
    "(#{node.row.visit(self)}, #{node.column.visit(self)})"
  end
  
  def visit_cell_right(node)
    "(#{node.row.visit(self)}, #{node.column.visit(self)})"
  end

  #BITWISE
  def visit_bitwise_and(node)
    "(#{node.left_node.visit(self)} & #{node.right_node.visit(self)})"
  end 

  def visit_bitwise_or(node)
    "(#{node.left_node.visit(self)} | #{node.right_node.visit(self)})"
  end

  def visit_bitwise_xor(node)
    "(#{node.left_node.visit(self)} ^ #{node.right_node.visit(self)})"
  end

  def visit_bitwise_not(node)
    negate = node.node.visit(self)
    "~#{negate}"
  end

  def visit_bitwise_left_shift(node)
    "(#{node.left_node.visit(self)} << #{node.right_node.visit(self)})"
  end

  def visit_bitwise_right_shift(node)
    "(#{node.left_node.visit(self)} >> #{node.right_node.visit(self)})"
  end

  #RELATIONAL
  def visit_equal(node)
    "(#{node.left_node.visit(self)} == #{node.right_node.visit(self)})"
  end

  def visit_not_equal(node)
    "(#{node.left_node.visit(self)} != #{node.right_node.visit(self)})"
  end

  def visit_less_than(node)
    "(#{node.left_node.visit(self)} < #{node.right_node.visit(self)})"
  end

  def visit_less_than_or_equal(node)
    "(#{node.left_node.visit(self)} <= #{node.right_node.visit(self)})"
  end

  def visit_greater_than(node)
    "(#{node.left_node.visit(self)} > #{node.right_node.visit(self)})"
  end

  def visit_greater_than_or_equal(node)
    "(#{node.left_node.visit(self)} >= #{node.right_node.visit(self)})"
  end

  #CAST
  def visit_cast_to_int(node)
    "(int)#{node.node.visit(self)}"
  end

  def visit_cast_to_float(node)
    "(float)#{node.node.visit(self)}"
  end

  #STAT
  def visit_max(node)
    "max(#{node.left_node.visit(self)}, #{node.right_node.visit(self)})"
  end

  def visit_min(node)
    "min(#{node.left_node.visit(self)}, #{node.right_node.visit(self)})"
  end

  def visit_mean(node)
    "mean(#{node.left_node.visit(self)}, #{node.right_node.visit(self)})"
  end

  def visit_sum(node)
    "sum(#{node.left_node.visit(self)}, #{node.right_node.visit(self)})"
  end
end