require_relative 'model/arithmetic.rb'
require_relative 'model/bitwise.rb'
require_relative 'model/cast.rb'
require_relative 'model/cell_vals.rb'
require_relative 'model/logical_ops.rb'
require_relative 'model/primitives.rb'
require_relative 'model/relational.rb'
require_relative 'model/stat_funcs.rb'
require_relative 'grid.rb'
require_relative 'evaluator.rb'
require_relative 'serializer.rb'
require_relative 'runtime.rb'

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