class Runtime
  def initialize(spreadsheet)
    @spreadsheet = spreadsheet
  end

  def get_cell(row, col)
    @spreadsheet.get_cell_value(row, col)
  end
end