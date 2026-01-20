#accepts list of tokens and assembles abstract syntax tree using model abstractions
#ex: 5<= 32.0 yields new LessThanOrEqual(new IntegeralLiteral(5,(0,0)), new FloatLiteral(32.0,(5,8)),(0,8))
#helper methods
#parse (parse complete list of tokens and return roo node of ast)
#has (see if next token has certain type)
#advance (move forward in tokens list 
#def method for each non terminal in grammar 

require_relative 'token'

class Parser
  def initialize(tokens)
    @tokens = tokens
    @curr_index = 0
  end

  # helper to go to next_t token
  def advance
    # out of bounds check
    if @curr_index >= @tokens.length
      return nil
    end
    token = @tokens[@curr_index]
    @curr_index += 1
    token

  end

  # check type of token 
  def has(type)
    if @curr_index >= @tokens.length
      return false
    end
    @curr_index < @tokens.length && @tokens[@curr_index].type == type
  end

  # error checking helper for type
  def expect_error(type)
    unless has(type)
      raise "Wrong type: #{@tokens[@curr_index].type} at #{@curr_index}, Expected: #{type}"
    end
    advance()
  end

  def parse
    #starting at highest precedence 
    expression = expression()
    if @curr_index < @tokens.length
      raise "Unexpected token: #{@tokens[@curr_index].type} at index #{@curr_index}"
    end
    expression
  end

  def expression 
    # logical, level0
    left_term = level0()
    while has(Types::LOG_OR) || has(Types::LOG_AND)
      operator = advance()
      right_term = level0()
      if operator.type == Types::LOG_AND
        left_term = Logic::And.new(left_term, right_term)
      elsif operator.type == Types::LOG_OR
        left_term = Logic::Or.new(left_term,right_term)
      end
    end
    left_term
  end

  # level0, bitwise 
  def level0
    left_term = level1()
    while has(Types::BIT_AND) || has(Types::BIT_OR) || has(Types::BIT_XOR)
      operator = advance()
      op_type = operator.type
      right_term = level1()
      if op_type == Types::BIT_AND
        left_term = Bitwise::BitAnd.new(left_term, right_term)
      elsif op_type == Types::BIT_OR
        left_term = Bitwise::BitOr.new(left_term, right_term)
      elsif op_type == Types::BIT_XOR
        left_term = Bitwise::BitXor.new(left_term, right_term) 
      end
    end
    left_term
  end

# level1, equality
def level1
  left_term = level2()
  while has(Types::EQUALS) || has(Types::NOT_EQUAL)
    operator = advance()
    right_term = level2()
    op_type =  operator.type
    if op_type == Types::EQUALS
      left_term = Relational::Equals.new(left_term, right_term)
    elsif op_type == Types::NOT_EQUAL
      left_term = Relational::NotEquals.new(left_term, right_term)
    end
  end
  left_term
end

# relational
def level2
  left_term = level3()
  while has(Types::LESS_THAN) || has(Types::LESS_THAN_EQUAL) || has(Types::GREATER_THAN) || has(Types::GREATER_THAN_EQUAL)
    operator = advance()
    right_term = level3()
    op_type = operator.type
    if op_type == Types::LESS_THAN
      left_term = Relational::LessThan.new(left_term, right_term)
    elsif op_type == Types::LESS_THAN_EQUAL
      left_term = Relational::LessThanEqual.new(left_term, right_term)
    elsif op_type == Types::GREATER_THAN
      left_term = Relational::GreaterThan.new(left_term, right_term)
    elsif op_type == Types::GREATER_THAN_EQUAL
      left_term = Relational::GreaterThanEqual.new(left_term, right_term)
    end
  end
  left_term
end

# bitwise shift 
def level3
  left_term = level4()
  while has(Types::LEFT_SHIFT) || has(Types::RIGHT_SHIFT)
    operator = advance()
    right_term = level4()
    op_type = operator.type
    if op_type == Types::LEFT_SHIFT
      left_term = Bitwise::LeftShift.new(left_term, right_term)
    elsif op_type == Types::RIGHT_SHIFT
      left_term = Bitwise::RightShift.new(left_term, right_term)
    end
  end
  left_term
end

# addition and subtraction
def level4
  left_term = level5()
  while has(Types::ADD) || has(Types::SUB)
    operator = advance()
    right_term = level5()
    op_type = operator.type
    if op_type == Types::ADD
      left_term = Arithmetic::Add.new(left_term, right_term)
    elsif op_type == Types::SUB
      left_term = Arithmetic::Subtract.new(left_term, right_term)
    end
  end
  left_term
end

# mult, div, and mod
def level5
  left_term = level6()
  while has(Types::MULT) || has(Types::DIV) || has(Types::MOD)
    operator = advance()
    right_term = level6()
    op_type =  operator.type
    if op_type == Types::MULT
      left_term = Arithmetic::Multiply.new(left_term, right_term)
    elsif op_type == Types::DIV
      left_term = Arithmetic::Divide.new(left_term, right_term)
    elsif op_type == Types::MOD
      left_term = Arithmetic::Modulo.new(left_term, right_term)
    end
  end
  left_term
end

# negation and NOT
def level6
  negation = 1
  if has(Types::SUB)
    advance()
    while has(Types::SUB)
      advance()
      negation += 1
    end
    if negation.odd?
      Arithmetic::Negation.new(level7)
    else
      level7()
    end
  elsif has(Types::LOG_NOT)
    advance()
    Logic::Not.new(level7)
  elsif has(Types::BIT_NOT)
    advance()
    Bitwise::BitNot.new(level7)
  else
    level7()
  end
end

# exponents
def level7
  left_term = level8()
  while has(Types::EXP)
    advance()
    right_term = level8()
    left_term = Arithmetic::Exponent.new(left_term, right_term)
  end
  left_term
end

# parenthesis, type cast, array, funcs
# doesnt fully work yet
def level8
  if has(Types::LEFT_PAR)
    advance()
    expression = expression()
    expect_error(Types::RIGHT_PAR)
    return expression
  elsif has(Types::LEFT_BRACKET)
    advance()
    row = expression()
    expect_error(Types::COMMA)
    col = expression()
    expect_error(Types::RIGHT_BRACKET)
    unless row.is_a?(Primitives::Integer) && col.is_a?(Primitives::Integer)
      raise "Brackets should include two integer values indicating a cell"
    end

    return CellValueL.new(row.raw_value, col.raw_value)

  elsif has(Types::FLOAT_CAST)
    advance()
    expression = expression()
    return Cast::IntToFloat.new(expression)
  elsif has(Types::INT_CAST)
    advance()
    expression = expression()
    return Cast::FloatToInt.new(expression)
  elsif has(Types::CELL_LVALUE)
    # Parse the cell reference
    cell_ref = advance().value
    row_col = cell_ref[2..-2].split(',')
    row = Primitives::Integer.new(row_col[0].strip.to_i)
    col = Primitives::Integer.new(row_col[1].strip.to_i)
    # Return a node that represents a cell value lookup
    return CellValueR.new(row.raw_value, col.raw_value)
  elsif has(Types::SUM) || has(Types::MIN) || has(Types::MAX) || has(Types::MEAN)
    func = advance()
    expect_error(Types::LEFT_PAR)
    left_term = expression()
    expect_error(Types::COMMA)
    right_term = expression()
    expect_error(Types::RIGHT_PAR)
    case func.type
    when Types::SUM
      return StatFuncs::Sum.new(left_term, right_term)
    when Types::MIN
      return StatFuncs::Min.new(left_term, right_term)
    when Types::MAX
      return StatFuncs::Max.new(left_term, right_term)
    when Types::MEAN
      return StatFuncs::Mean.new(left_term, right_term)
    end
  elsif has(Types::INT)
    return Primitives::Integer.new(advance.value.to_i)
  elsif has(Types::FLOAT)
    return Primitives::Float.new(advance.value.to_f)
  elsif has(Types::ID)
    return Primitives::String.new(advance.value)
  else
    raise "Unexpected token: #{@tokens[@curr_index].type} at #{@curr_index}"
  end
end

end
