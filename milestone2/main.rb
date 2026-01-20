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
require_relative 'lexer.rb'
require_relative 'parser.rb'

# USING GRID
grid = Grid.new(15,15)
runtime = Runtime.new(grid)

# HELPER TO ADD TO GRID, EVALUATE AND SERIALIZE
def grid_expression(grid,runtime,row,col,expression)
    grid.set_cell(row,col,expression, runtime)
    result = grid.get_cell(row,col)
    serialized = expression.visit(Serializer.new)
    puts "Address[#{row}, #{col}]: #{serialized}, raw_val: #{result.raw_value}"
    puts("\n")
end


# Arithmetic: (7 * 4 + 3) % 12 = 7
puts("ARITHMETIC")
arithmetic = Arithmetic::Modulo.new(
    Arithmetic::Add.new(
        Arithmetic::Multiply.new(
            Primitives::Integer.new(7),
            Primitives::Integer.new(4)
        ),
        Primitives::Integer.new(3)
    ),
    Primitives::Integer.new(12)
)
grid_expression(grid,runtime,0,1,arithmetic) 

# Arithmetic negation and cell rvalues: #[3, 1] * -#[2, 1]
#set grid values
puts("ARITHMETIC NEGATION")
puts("GRID VALUES:")
grid_expression(grid,runtime,3, 1, Primitives::Integer.new(5))
grid_expression(grid,runtime,2, 1, Primitives::Integer.new(5))
arithmetic_negation = Arithmetic::Multiply.new(
    CellValueR.new(3,1),
    Arithmetic::Negation.new(CellValueR.new(2,1)))
grid_expression(grid, runtime,3,3,arithmetic_negation)

# Rvalue lookup and shift: #[1 + 1, 4] << 3 (5<<3)
puts("RVALUE LOOKUP AND SHIFT")
val_one = Primitives::Integer.new(1)
cell_val = Arithmetic::Add.new(val_one,val_one)
puts("GRID VALUES:")
grid_expression(grid,runtime,1,1,cell_val)
lookup_shift = Bitwise::LeftShift.new(
    CellValueR.new(1,1),
    Primitives::Integer.new(3)
)
grid_expression(grid,runtime,5,3,lookup_shift)


# Rvalue lookup and comparison: #[0, 0] < #[0, 1]
puts("RVALUE LOOKUP AND COMP")
puts("GRID VALUES:")
grid_expression(grid,runtime,2,2,Primitives::Float.new(1.2))
grid_expression(grid,runtime,2,3,Primitives::Float.new(2.1))
lookup_comparison = Relational::LessThan.new(
    CellValueR.new(2,2),
    CellValueR.new(2,3)
)
grid_expression(grid,runtime,2,4,lookup_comparison)

# Logic and comparison: !(3.3 > 3.2)
puts("LOGIC AND COMPARISON")
logic_comp = Logic::Not.new(
    Relational::GreaterThan.new(
        Primitives::Float.new(3.3),
        Primitives::Float.new(3.2)
    )
)
grid_expression(grid,runtime, 12,11, logic_comp)

# Double negation: --(6 * 8)
puts("DOUBLE NEGATION")
double_neg = Arithmetic::Negation.new(Arithmetic::Negation.new(
    Arithmetic::Multiply.new(
        Primitives::Integer.new(6),
        Primitives::Integer.new(8)
    )
))
grid_expression(grid,runtime,12,12, double_neg)

# Bitwise operations: ~5 | ~8
puts("BITWISE OPS")
bitwise_op = Bitwise::BitOr.new(
    Bitwise::BitNot.new(Primitives::Integer.new(5)),
    Bitwise::BitNot.new(Primitives::Integer.new(8))
)
grid_expression(grid,runtime,12,13,bitwise_op)

# USE FOR STATS FUNC
cellval1 = CellValueL.new(1,2)
cellval2 = CellValueL.new(5,3)

# Sum: sum([1, 2], [5, 3])
puts("SUM")
sum = StatFuncs::Sum.new(cellval1,cellval2)
grid_expression(grid,runtime, 14,10,sum)

# Mean: mean([1, 2], [5, 3])
puts("MEAN")
mean = StatFuncs::Mean.new(cellval1,cellval2)
grid_expression(grid,runtime, 14,11,mean)

# Min: min([1, 2], [5, 3])
puts("MIN")
min = StatFuncs::Min.new(cellval1,cellval2)
grid_expression(grid,runtime, 14,12,min)

# Max: max([1, 2], [5, 3])
puts("MAX")
max = StatFuncs::Max.new(cellval1,cellval2)
grid_expression(grid,runtime, 14,13,max)

# Casting: float(7) / 2
puts("CASTING INT TO FLOAT")
int_to_float = Cast::IntToFloat.new(Primitives::Integer.new(7))
div1 = Arithmetic::Divide.new(int_to_float,Primitives::Integer.new(2))
# should print 3.5 
grid_expression(grid,runtime, 14,14,div1)

# Casting float to int always floors to X.0
# float(3.8) -> 3
puts("CASTING FLOAT TO INT")
float_to_int = Cast::FloatToInt.new(Primitives::Float.new(3.8))
grid_expression(grid,runtime,13,13,float_to_int)

# Error Checking
# puts("ERROR CHECKING")

# should not divide by 0
invalid = Arithmetic::Divide.new(Primitives::Integer.new(7),Primitives::Integer.new(0))
#grid_expression(grid,runtime, 14,15,invalid)

# using wrong class
float_to_float = Cast::IntToFloat.new(Primitives::Float.new(3.8))
#grid_expression(grid,runtime,13,14,float_to_float)

# not same class
less_than = Relational::LessThan.new(Primitives::Integer.new(7),Primitives::Float.new(3.8))
#grid_expression(grid,runtime,13,15,less_than)

## MILESTONE 2: testing lexer and tokens
# helper for lexing and parsing
def test_parser(expression, grid, runtime)
  # Using lexer to tokenize expression
  lexer = Lexer.new(expression)
  tokens = lexer.lex
  puts "Expression: #{expression}"
  puts "LEXING Tokens:"
  tokens.each { |token| puts "  #{token}" }
  puts "\n"
  
  # Parsing the tokens
  puts "PARSING:"
  parser = Parser.new(tokens)
  ast = parser.parse

  # Serialize to check if correct order of operations and result
  serialized_ast = ast.visit(Serializer.new)
  puts "Serialized AST: #{expression} = #{serialized_ast}"

  # Evaluate the AST
  evaluator = Evaluator.new(runtime)
  result = ast.visit(evaluator)

  # If the result is a primitive, use its raw value for evaluation
  evaluated_result = result.raw_value if result.respond_to?(:raw_value)

  puts "Evaluated Result: #{evaluated_result}"
  puts "\n"
end

puts("MILESTONE 2: TESTING LEXER, TOKENS, PARSING")

#Cell value lookup test
#set [0, 0] to 5
grid_expression(grid,runtime,0, 0, Primitives::Integer.new(5))
#set [1, 1] to 10
grid_expression(grid,runtime,1, 1, Primitives::Integer.new(10))

test_parser("5 + 2 * 3 % 4", grid, runtime)  # Arithmetic: (5 + 2) * 3 % 4
test_parser("#[0, 0] + 3", grid, runtime)    # Rvalue lookup and shift: #[0, 0] + 3
test_parser("#[0, 0] < #[1, 1]", grid, runtime)  # Rvalue lookup and comparison: #[1 - 1, 0] < #[1 * 1, 1]
test_parser("(5 > 3) && !(2 > 8)", grid, runtime)  # Logic and comparison: (5 > 3) && !(2 > 8)
test_parser("float(10) / 4.0", grid, runtime)  # Casting: float(10) / 4.0
test_parser("2 ** 3 ** 2", grid, runtime)  # Exponentiation: 2 ** 3 ** 2
test_parser("1 + sum([0, 0], [1, 1])", grid, runtime)  # Sum: 1 + sum([0, 0], [2, 1])
test_parser("45 & ---(1 + 3)", grid, runtime)  # Negation and bitwise and: 45 & ---(1 + 3)