module Primitives
  class Integer
    attr_reader :raw_value 

    def initialize(raw_value)
      @raw_value = raw_value 
    end
    def visit(visitor)
      visitor.visit_integer(self)
    end
  end

  class Float
    attr_reader :raw_value

    def initialize(raw_value)
      @raw_value = raw_value
    end

    def visit(visitor)
      #write visit_float function
      visitor.visit_float(self)
    end
  end

  class Boolean
    attr_reader :raw_value
    
    def initialize(raw_value)
      @raw_value = raw_value
    end
    def visit(visitor)
      visitor.visit_boolean(self)
    end
  end

  class String
    attr_reader :raw_value
    def initialize(raw_value)
      @raw_value= raw_value
    end
    
    def visit(visitor)
      visitor.visit_string(self)
    end
  end

  class CellAddress
    attr_reader :row, :col

    def initialize(row, col)
      @row = row
      @col = col
    end

    def raw_value
      "#{@row},#{@col}"
    end
    
    def visit(visitor)
      visitor.visit_cell_address(self)
    end
  end

end


