# Require the curses library for terminal-based UI
require 'curses'

require_relative '../milestone1/model/arithmetic.rb'
require_relative '../milestone1/model/bitwise.rb'
require_relative '../milestone1/model/cast.rb'
require_relative '../milestone1/model/cell_vals.rb'
require_relative '../milestone1/model/logical_ops.rb'
require_relative '../milestone1/model/primitives.rb'
require_relative '../milestone1/model/relational.rb'
require_relative '../milestone1/model/stat_funcs.rb'
require_relative '../milestone1/grid.rb'
require_relative '../milestone1/evaluator.rb'
require_relative '../milestone1/serializer.rb'
require_relative '../milestone1/runtime.rb'

require_relative '../milestone2/lexer.rb'
require_relative '../milestone2/parser.rb'
require_relative '../milestone2/token.rb'

# Spreadsheet class represents the core data structure and cursor management
class Spreadsheet
  attr_accessor :grid, :cursor_row, :cursor_col, :grid_size, :formulas, :dependencies

  # Initialize a new spreadsheet
  def initialize(grid_size)
    @grid_size = grid_size
    # Create a 2D array filled with empty strings
    @grid = Array.new(grid_size) { Array.new(grid_size, "") }
    @formulas = Array.new(grid_size) { Array.new(grid_size, nil) } # Store formulas
    @dependencies = Hash.new { |hash, key| hash[key] = [] } # Track dependencies
    # Initialize cursor position at top-left corner (0,0)
    @cursor_row = 0
    @cursor_col = 0
    @error_message = nil # Initialize error message
  end

  # Move the cursor in the specified direction with boundary checking
  def move_cursor(direction)
    case direction
    when :up    then @cursor_row = [@cursor_row - 1, 0].max          # Move up, don't go above row 0
    when :down  then @cursor_row = [@cursor_row + 1, @grid_size - 1].min # Move down, don't go below last row
    when :left  then @cursor_col = [@cursor_col - 1, 0].max          # Move left, don't go before column 0
    when :right then @cursor_col = [@cursor_col + 1, @grid_size - 1].min # Move right, don't go after last column
    end
  end

  # Get the content of the current cell
  def current_cell
    @grid[@cursor_row][@cursor_col]
  end

  # Set the content of the current cell
  def current_cell=(value)
    if value.start_with?("=")
      # Store the formula
      @formulas[@cursor_row][@cursor_col] = value
      update_dependencies(@cursor_row, @cursor_col, value)
    else
      clear_dependencies(@cursor_row, @cursor_col)
      @formulas[@cursor_row][@cursor_col] = nil
      if value.match?(/\A[-+]?\d+\z/) # Integer
        @grid[@cursor_row][@cursor_col] = Primitives::Integer.new(value.to_i).raw_value.to_s
      elsif value.match?(/\A[-+]?\d*\.\d+\z/) # Float
        @grid[@cursor_row][@cursor_col] = Primitives::Float.new(value.to_f).raw_value.to_s
      elsif %w[true false].include?(value.downcase) # Boolean
        @grid[@cursor_row][@cursor_col] = Primitives::Boolean.new(value.downcase == "true").raw_value.to_s
      else
        # Treat as plain string
        @grid[@cursor_row][@cursor_col] = value
      end
    end
    recheck_all_cells # Recheck all cells after updating
  end

  # Recheck and evaluate all cells
  def recheck_all_cells
    (0...@grid_size).each do |row|
      (0...@grid_size).each do |col|
        evaluate_cell(row, col) if @formulas[row][col]
      end
    end
  end

  def evaluate_cell(row, col)
    formula = @formulas[row][col]
    if formula
      begin
        lexer = Lexer.new(formula[1..]) # Remove '=' before lexing
        tokens = lexer.lex
        parser = Parser.new(tokens)
        expression = parser.parse
        runtime = Runtime.new(self) # Pass the spreadsheet as the runtime
        evaluated_result = expression.visit(Evaluator.new(runtime))
        @grid[row][col] = evaluated_result.raw_value.to_s
      rescue => e
        @grid[row][col] = "ERROR" # Display "ERROR" in the cell
        @error_message = e.message # Store the error message for display
      end
    end
  end

  def error_message
    @error_message
  end

  def update_dependencies(row, col, formula)
    clear_dependencies(row, col)
    lexer = Lexer.new(formula[1..]) # Remove '=' before lexing
    tokens = lexer.lex
    tokens.each_with_index do |token, index|
      if token.type == :CELL_REF
        ref_row, ref_col = extract_cell_reference(tokens[index + 1])
        @dependencies[[ref_row, ref_col]] << [row, col]
      end
    end
  end

  def clear_dependencies(row, col)
    @dependencies.each { |_, dependents| dependents.delete([row, col]) }
  end

  def update_dependent_cells(row, col)
    @dependencies[[row, col]].each do |dependent_row, dependent_col|
      evaluate_cell(dependent_row, dependent_col)
      update_dependent_cells(dependent_row, dependent_col)
    end
  end

  def extract_cell_reference(token)
    match = token.value.match(/\[(\d+),\s*(\d+)\]/)
    [match[1].to_i, match[2].to_i]
  end

  # Get the value of a referenced cell
  def get_cell_value(row, col)
    row = row.raw_value if row.is_a?(Primitives::Integer)
    col = col.raw_value if col.is_a?(Primitives::Integer)
    raise "Cell [#{row}, #{col}] is out of bounds" if row >= @grid_size || col >= @grid_size
    value = @grid[row][col]
    raise "Cell [#{row}, #{col}] is undefined" if value.nil? || value.empty?
    value.match?(/\A[-+]?\d+\z/) ? Primitives::Integer.new(value.to_i) : Primitives::Float.new(value.to_f)
  end
end

# Configuration class for all UI layout constants
class SpreadsheetConfig
  # Grid cell dimensions
  CELL_WIDTH = 10    # Width of each cell in characters
  CELL_HEIGHT = 2   # Height of each cell in lines

  # Grid size (number of rows and columns)
  GRID_SIZE = 8

  # Window layout padding
  SCREEN_PADDING = 1        # General padding around the grid
  GRID_TOP_PADDING = 2      # Space above the grid for column labels
  GRID_LEFT_PADDING = 4     # Space left of the grid for row labels
  ROW_LABEL_WIDTH = 3       # Width reserved for row numbers

  # Panel dimensions
  PANEL_WIDTH = 50          # Width of the right-side panel
  EDITOR_HEIGHT = 3         # Height of the formula editor panel
  DISPLAY_HEIGHT = 3        # Height of the display panel
  INSTRUCTIONS_HEIGHT = 13  # Height of the instructions panel
  FOOTER_HEIGHT = 1         # Height of the footer

  # Calculate window positions and sizes based on terminal dimensions
  def self.calculate_layout(screen_width, screen_height)
    # Calculate grid dimensions
    grid_width = GRID_LEFT_PADDING + (CELL_WIDTH * GRID_SIZE) + 2
    panel_x = grid_width + 1  # X position where the panel starts

    {
      grid_width: grid_width,
      grid_height: screen_height - FOOTER_HEIGHT,
      panel_width: [PANEL_WIDTH, screen_width - grid_width - 1].min, # Ensure panel fits on screen
      panel_x: panel_x,
      editor_height: EDITOR_HEIGHT,
      display_height: DISPLAY_HEIGHT,
      instructions_height: INSTRUCTIONS_HEIGHT,
      footer_height: FOOTER_HEIGHT,
      editor_y: 0,  # Editor is at the top of the panel
      display_y: EDITOR_HEIGHT,  # Display is below editor
      instructions_y: EDITOR_HEIGHT + DISPLAY_HEIGHT,  # Instructions below display
      footer_y: screen_height - FOOTER_HEIGHT  # Footer at bottom of screen
    }
  end
end

# Draw the spreadsheet grid with labels and cursor highlighting
def draw_grid(grid_window, spreadsheet)
  # Draw column labels (numbers at the top)
  (0...spreadsheet.grid_size).each do |col|
    # Calculate x position centered under each column
    label_x = col * SpreadsheetConfig::CELL_WIDTH + SpreadsheetConfig::GRID_LEFT_PADDING + (SpreadsheetConfig::CELL_WIDTH / 2)
    grid_window.setpos(SpreadsheetConfig::SCREEN_PADDING, label_x)
    grid_window.addstr(col.to_s)
  end

  # Draw each row of the grid
  (0...spreadsheet.grid_size).each do |row|
    # Draw row label (number at the left)
    grid_window.setpos(row * SpreadsheetConfig::CELL_HEIGHT + SpreadsheetConfig::GRID_TOP_PADDING, SpreadsheetConfig::SCREEN_PADDING)
    grid_window.addstr(row.to_s.ljust(SpreadsheetConfig::ROW_LABEL_WIDTH))

    # Draw each cell in the row
    (0...spreadsheet.grid_size).each do |col|
      # Calculate cell position
      top_left_x = col * SpreadsheetConfig::CELL_WIDTH + SpreadsheetConfig::GRID_LEFT_PADDING
      top_left_y = row * SpreadsheetConfig::CELL_HEIGHT + SpreadsheetConfig::GRID_TOP_PADDING

      # Check if this is the current cell (has cursor)
      if row == spreadsheet.cursor_row && col == spreadsheet.cursor_col
        # Draw highlighted cell with reverse video
        (0..SpreadsheetConfig::CELL_HEIGHT).each do |cell_line|
          grid_window.setpos(top_left_y + cell_line, top_left_x)
          grid_window.attron(Curses::A_REVERSE)
          if cell_line == 0 || cell_line == SpreadsheetConfig::CELL_HEIGHT
            # Draw top and bottom borders
            grid_window.addstr("+" + "-" * (SpreadsheetConfig::CELL_WIDTH - 1) + "+")
          else
            # Draw cell content with padding
            cell_content = spreadsheet.grid[row][col][0..(SpreadsheetConfig::CELL_WIDTH - 3)] || ""
            padding = " " * (SpreadsheetConfig::CELL_WIDTH - 2 - cell_content.length)
            grid_window.addstr("| #{cell_content}#{padding}|")
          end
          grid_window.attroff(Curses::A_REVERSE)
        end
      else
        # Draw normal (non-highlighted) cell
        # Top border
        grid_window.setpos(top_left_y, top_left_x)
        grid_window.addstr("+" + "-" * (SpreadsheetConfig::CELL_WIDTH - 1) + "+")

        # Cell content
        grid_window.setpos(top_left_y + 1, top_left_x)
        cell_content = spreadsheet.grid[row][col][0..(SpreadsheetConfig::CELL_WIDTH - 3)] || ""
        padding = " " * (SpreadsheetConfig::CELL_WIDTH - 2 - cell_content.length)
        grid_window.addstr("| #{cell_content}#{padding}|")

        # Bottom border
        grid_window.setpos(top_left_y + 2, top_left_x)
        grid_window.addstr("+" + "-" * (SpreadsheetConfig::CELL_WIDTH - 1) + "+")
      end
    end
  end

  grid_window.refresh
end

# Update the formula editor panel with current cell content or error message
def update_editor(editor_window, spreadsheet)
  editor_window.box("|", "-") # Redraw the border dynamically
  editor_window.setpos(1, 1)
  editor_window.clrtoeol  # Clear the line before writing
  formula = spreadsheet.formulas[spreadsheet.cursor_row][spreadsheet.cursor_col]
  if formula
    editor_window.addstr("Formula: #{formula}") # Show the formula or error message
  else
    editor_window.addstr("Formula: #{spreadsheet.current_cell}") # Show the evaluated value
  end
  editor_window.refresh
end

# Update the instructions panel with usage information and cursor position
def update_instructions(instructions_window, spreadsheet)
  # Draw border and title
  instructions_window.box("|", "-")
  instructions_window.setpos(0, 1)
  instructions_window.addstr(" Instructions ")
  
  # List of instructions to display
  instructions = [
    "WASD: Move cursor    Cell Ref: =#[row, col]",
    "e/Enter: Edit cell   Equations start with '='",
    "In edit mode:        Example: =2 * 3 = 6",
    "  Backspace: Delete",
    "  Enter: Confirm",
    "  Escape: Cancel",
    "q: Quit",
    "",
    "",
    "",
    "Row: #{spreadsheet.cursor_row}, Col: #{spreadsheet.cursor_col}" # Add cursor position here
  ]

  # Write each instruction on a new line
  instructions.each_with_index do |instruction, index|
    instructions_window.setpos(index + 1, 1)
    instructions_window.addstr(instruction)
  end
  
  instructions_window.refresh
end

# Update the display panel with current cell content or error message
def update_display(display_window, spreadsheet)
  display_window.box("|", "-") # Redraw the border dynamically
  display_window.setpos(1, 1)
  display_window.clrtoeol
  if spreadsheet.current_cell == "ERROR"
    display_window.addstr("Error: #{spreadsheet.error_message}") # Show error message
  else
    display_window.addstr("Cell: #{spreadsheet.current_cell}") # Show cell content
  end
  display_window.refresh
end

# Update the footer with exit information
def update_footer(footer_window)
  footer_window.setpos(0, 0)
  footer_window.clrtoeol  # Clear the entire line
  footer_window.addstr("Press 'q' to exit".center(footer_window.maxx))  # Center the text
  footer_window.refresh
end

# Main application execution block
begin
  # Initialize curses
  Curses.init_screen
  Curses.curs_set(0)  # Hide the cursor (we'll draw our own)
  Curses.noecho       # Don't echo typed characters

  # Get terminal dimensions
  screen_height = Curses.lines
  screen_width = Curses.cols

  # Calculate window positions and sizes
  layout = SpreadsheetConfig.calculate_layout(screen_width, screen_height)

  # Create windows
  grid_window = Curses::Window.new(layout[:grid_height], layout[:grid_width], 0, 0)
  editor_window = Curses::Window.new(layout[:editor_height], layout[:panel_width], layout[:editor_y], layout[:panel_x])
  display_window = Curses::Window.new(layout[:display_height], layout[:panel_width], layout[:display_y], layout[:panel_x])
  instructions_window = Curses::Window.new(layout[:instructions_height], layout[:panel_width], layout[:instructions_y], layout[:panel_x])
  footer_window = Curses::Window.new(layout[:footer_height], screen_width, layout[:footer_y], 0)

  # Initialize spreadsheet
  spreadsheet = Spreadsheet.new(SpreadsheetConfig::GRID_SIZE)

  # Draw initial UI
  editor_window.box("|", "-")
  editor_window.setpos(0, 1)
  editor_window.addstr(" Formula Editor ")
  
  display_window.box("|", "-")
  display_window.setpos(0, 1)
  display_window.addstr(" Display Panel ")
  
  update_instructions(instructions_window, spreadsheet)
  update_footer(footer_window)

  # Main input loop
  loop do
    # Update UI components
    draw_grid(grid_window, spreadsheet)
    update_editor(editor_window, spreadsheet)
    update_instructions(instructions_window, spreadsheet) # Update instructions with cursor position
    update_display(display_window, spreadsheet)

    ch = editor_window.getch

    case ch
    when 'q', 'Q'  # Quit the application
      break
    when 'w', 'W'  # Move cursor up
      spreadsheet.move_cursor(:up)
    when 's', 'S'  # Move cursor down
      spreadsheet.move_cursor(:down)
    when 'a', 'A'  # Move cursor left
      spreadsheet.move_cursor(:left)
    when 'd', 'D'  # Move cursor right
      spreadsheet.move_cursor(:right)
    when 'e', 'E', 10  # Enter or 'e' to edit
      # Enter editing mode
      editor_window.setpos(1, 1)
      editor_window.clrtoeol
      current_formula = spreadsheet.formulas[spreadsheet.cursor_row][spreadsheet.cursor_col]
      current_value = spreadsheet.current_cell
      input = current_formula || current_value.dup # Start with existing formula or value
      editor_window.addstr("Editing: #{input}")
      Curses.curs_set(1)  # Show cursor

      loop do
        ch = editor_window.getch
        case ch
        when 10 # Enter key to save
          if input.strip.empty?
            # Clear the cell if input is empty
            spreadsheet.formulas[spreadsheet.cursor_row][spreadsheet.cursor_col] = nil
            spreadsheet.grid[spreadsheet.cursor_row][spreadsheet.cursor_col] = ""
          else
            spreadsheet.current_cell = input
          end
          break
        when 27 # Escape key to cancel
          break
        when Curses::Key::BACKSPACE, 127, 8 # Backspace key
          input = input[0...-1] unless input.empty? # Remove the last character
        else
          input += ch.to_s if ch.is_a?(String) # Append character
        end

        # Update the editor window with the current input
        editor_window.setpos(1, 1)
        editor_window.clrtoeol
        editor_window.addstr("Editing: #{input}")
      end

      Curses.curs_set(0)  # Hide cursor
    end
  end

rescue => e
  Curses.close_screen
  puts "An error occurred: #{e.message}"
  puts e.backtrace
ensure
  Curses.close_screen
end