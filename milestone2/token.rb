class Token 
  attr_reader :type, :value, :pos
  def initialize(type, value, pos)
    @type = type
    @value = value
    @pos = pos
  end

  def to_s
    "#{@value} -  Type: #{@type}   Pos: #{@pos}\n"
  end
end

class Types
  # arithmetic
  ADD = :add
  SUB = :sub
  MULT = :mult
  DIV = :div
  MOD = :mod
  EXP = :exp

  # logical ops
  LOG_AND = :log_and
  LOG_OR = :log_or
  LOG_NOT = :log_not

  # bitwise
  BIT_AND = :bit_and
  BIT_OR = :bit_or
  BIT_XOR = :bit_xor
  BIT_NOT = :bit_not
  LEFT_SHIFT = :left_shift
  RIGHT_SHIFT = :right_shift

  # relational ops
  LESS_THAN = :less_than
  LESS_THAN_EQUAL = :less_than_equal
  GREATER_THAN = :greater_than
  GREATER_THAN_EQUAL = :greater_than_equal
  EQUALS = :equals
  NOT_EQUAL = :not_equal

  # assignment
  ASSIGN = :assign

  # parenthesis
  LEFT_PAR = :left_par
  RIGHT_PAR = :right_par
  LEFT_BRACKET = :left_bracket
  RIGHT_BRACKET = :right_bracket
  COMMA = :comma

  # cell ref
  CELL_LVALUE = :cell_lvalue

  # primitives
  INT = :int
  FLOAT = :float

  # stats funcs
  SUM = :sum
  MIN = :min
  MAX = :max
  MEAN = :mean

  # casting
  FLOAT_CAST = :float_cast
  INT_CAST = :int_cast

  # identifiers
  ID = :id
end
