class Grid
  # Store cells in a collection
  def initialize(rows, cols)
    @cells = Array.new(rows) { Array.new(cols, nil) }
  end

  def get_cell(row, col)
    # Extract raw values if row and col are Primitives::Integer
    row = row.raw_value if row.is_a?(Primitives::Integer)
    col = col.raw_value if col.is_a?(Primitives::Integer)

    # Throw error if cell doesn't exist
    if @cells[row][col].nil?
      return nil
    end

    return @cells[row][col][:value]
  end

  def set_cell(row, col, expr, runtime)
    value = expr.visit(Evaluator.new(runtime))
    @cells[row][col] = { expr: expr, value: value }
  end
end