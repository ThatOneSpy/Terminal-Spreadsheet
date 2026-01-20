class CellValueL
    attr_reader :row, :column
    def initialize(row, column)
        @row = Primitives::Integer.new(row)
        @column = Primitives::Integer.new(column)
    end
    def visit(visitor)
        visitor.visit_cell_left(self)
    end
end

class CellValueR
    attr_reader :row, :column
    def initialize(row, column)
        @row = Primitives::Integer.new(row)
        @column = Primitives::Integer.new(column)
    end
    def visit(visitor)
        visitor.visit_cell_right(self)
    end
end