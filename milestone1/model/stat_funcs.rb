module StatFuncs
  class Max 
    attr_reader :left_node, :right_node

    def initialize(left_node, right_node)
      @left_node = left_node
      @right_node = right_node
    end
    def visit(visitor)
      visitor.visit_max(self)
    end
  end

  class Min 
    attr_reader :left_node, :right_node

    def initialize(left_node, right_node)
      @left_node = left_node
      @right_node = right_node
    end
    def visit(visitor)
      visitor.visit_min(self)
    end
  end

  class Mean 
    attr_reader :left_node, :right_node

    def initialize(left_node, right_node)
      @left_node = left_node
      @right_node = right_node
    end
    def visit(visitor)
      visitor.visit_mean(self)
    end
  end

  class Sum 
    attr_reader :left_node, :right_node

    def initialize(left_node, right_node)
      @left_node = left_node
      @right_node = right_node
    end
    def visit(visitor)
      visitor.visit_sum(self)
    end
  end
end