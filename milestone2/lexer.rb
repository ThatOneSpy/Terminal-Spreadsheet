#accepts expression in text form and tokenizes it into list of tokens
#ex: 5<= 32.0 yields [:integer_literal, "5",0,0),[:less__than_or_equal, "<=",2,3]] ints are indices of token
#do not assume tokens are separed by whitespace , dont use split
#sgould just chunk characters into tokens'

require_relative 'token.rb'
class Lexer
  attr_reader :tokens
  
  def initialize(input)
    @input = input
    @pos = 0
    @start_i = 0
    @token_so_far = ''
    @tokens = []
  end

  def has(char)
    @pos < @input.length && @input[@pos] == char
  end

  def has_digit
    @pos < @input.length && @input[@pos] =~ /\d/
  end
  def has_alpha
    @pos < @input.length && @input[@pos] =~ /[a-zA-Z_]/
  end

  def has_alphanumeric
    @pos < @input.length && @input[@pos] =~ /[a-zA-Z0-9_]/
  end

  def capture
    @token_so_far += @input[@pos]
    @pos += 1
  end

  def emit_token(type)
    @tokens << Token.new(type, @token_so_far, @start_i)
    @token_so_far = ''
  end

  def lex
    while @pos < @input.length
      @start_i = @pos
      if has(' ')
        @pos +=1
      elsif has('+')
        capture
        emit_token(Types::ADD)
      elsif has('-')
        capture
        emit_token(Types::SUB)
      elsif has('*')
        capture
        if has('*')
          capture
          emit_token(Types::EXP)
        else
          emit_token(Types::MULT)
        end
      elsif has('/')
        capture
        emit_token(Types::DIV)
      elsif has('%')
        capture
        emit_token(Types::MOD)
      elsif has(',')
        capture
        emit_token(Types::COMMA)
      elsif has('(')
        capture
        emit_token(Types::LEFT_PAR)
      elsif has(')')
        capture
        emit_token(Types::RIGHT_PAR)
      elsif has('[')
        capture
        emit_token(Types::LEFT_BRACKET)
      elsif has(']')
        capture
        emit_token(Types::RIGHT_BRACKET)
      elsif has('#') && @pos + 1 < @input.length && @input[@pos + 1] == '['
        capture
        while @input[@pos] != ']'
          capture
        end
        capture
        emit_token(Types::CELL_LVALUE)

      elsif has('<')
        capture
        if has('=')
          capture
          emit_token(Types::LESS_THAN_EQUAL)
        elsif has('<')
          capture
          emit_token(Types::LEFT_SHIFT)
        else
          emit_token(Types::LESS_THAN)
        end
      elsif has('>')
        capture
        if has('=')
          capture
          emit_token(Types::GREATER_THAN_EQUAL)
        elsif has('>')
          capture
          emit_token(Types::RIGHT_SHIFT)
        else
          emit_token(Types::GREATER_THAN)
        end
      elsif has('=')
        capture
        if has('=')
          capture
          emit_token(Types::EQUALS)
        else
          emit_token(Types::ASSIGN)
        end
      elsif has('!')
        capture
        if has('=')
          capture
          emit_token(Types::NOT_EQUAL)
        else
          emit_token(Types::LOG_NOT)
        end
      elsif has('~')
        capture
        emit_token(Types::BIT_NOT)
      elsif has('&')
        capture
        if has('&')
          capture
          emit_token(Types::LOG_AND)
        else
          emit_token(Types::BIT_AND)
        end
      elsif has('|')
        capture
        if has('|')
          capture
          emit_token(Types::LOG_OR)
        else
          emit_token(Types::BIT_OR)
        end
      elsif has('^')
        capture
        emit_token(Types::BIT_XOR)
      elsif has_digit
        while has_digit
          capture
        end
        if has('.')
          capture
          while has_digit
            capture
          end
          emit_token(Types::FLOAT)
        else
          emit_token(Types::INT)
        end
      elsif has_alpha
        while has_alphanumeric
          capture
        end
        case @token_so_far
        when 'sum'
          emit_token(Types::SUM)
        when 'min'
          emit_token(Types::MIN)
        when 'max'
          emit_token(Types::MAX)
        when 'mean'
          emit_token(Types::MEAN)
        when 'float'
          emit_token(Types::FLOAT_CAST)
        when 'int'
          emit_token(Types::INT_CAST)
        else
          emit_token(Types::ID)
        end
      else
        raise "Unexpected character: #{@input[@pos]} at index #{@pos}"
      end
    end
    @tokens
  end 

end