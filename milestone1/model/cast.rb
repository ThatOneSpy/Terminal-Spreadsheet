module Cast
  class FloatToInt
    attr_reader :node

    def initialize(node)
      @node = node
    end

    def visit(visitor)
      visitor.visit_cast_to_int(self)
    end
  end

  class IntToFloat
    attr_reader :node

    def initialize(node)
      @node = node
    end

    def visit(visitor)
      visitor.visit_cast_to_float(self)
    end
  end
end
