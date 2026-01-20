class Evaluator
    def initialize(runtime)
        @runtime = runtime
    end
    # PRIMITIVES
    def visit_integer(node)
        node
    end

    def visit_float(node)
        node
    end

    def visit_boolean(node)
        node
    end

    def visit_string(node)
        node
    end

    def visit_cell_address(node)
        node
    end

    #ARITHMETIC
    def visit_add(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking
        raise TypeError, 'left node is not a int or float' unless left_primitive.is_a?(Primitives::Integer) || left_primitive.is_a?(Primitives::Float)
        raise TypeError, 'right node is not a int or float' unless right_primitive.is_a?(Primitives::Integer) || right_primitive.is_a?(Primitives::Float)

        #add the two values
        result = left_primitive.raw_value + right_primitive.raw_value

        #return the result as a integer or float depending on the type of the result
        if left_primitive.is_a?(Primitives::Integer)
            Primitives::Integer.new(result)
        else
            #round to 3 decimal places
            result = result.round(3)
            Primitives::Float.new(result)
        end
    end

    def visit_subtract(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking
        raise TypeError, 'left node is not a int or float' unless left_primitive.is_a?(Primitives::Integer) || left_primitive.is_a?(Primitives::Float)
        raise TypeError, 'right node is not a int or float' unless right_primitive.is_a?(Primitives::Integer) || right_primitive.is_a?(Primitives::Float)

        #subtract the two values
        result = left_primitive.raw_value - right_primitive.raw_value

        #return the result as a integer or float depending on the type of the result
        if left_primitive.is_a?(Primitives::Integer)
            Primitives::Integer.new(result)
        else
            #round to 3 decimal places
            result = result.round(3)
            Primitives::Float.new(result)
        end
    end

    def visit_multiply(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking
        raise TypeError, 'left node is not a int or float' unless left_primitive.is_a?(Primitives::Integer) || left_primitive.is_a?(Primitives::Float)
        raise TypeError, 'right node is not a int or float' unless right_primitive.is_a?(Primitives::Integer) || right_primitive.is_a?(Primitives::Float)

        #multiply the two values
        result = left_primitive.raw_value * right_primitive.raw_value

        #return the result as a integer or float depending on the type of the result
        if left_primitive.is_a?(Primitives::Integer)
            Primitives::Integer.new(result)
        else
            #round to 3 decimal places
            result = result.round(3)
            Primitives::Float.new(result)
        end
    end

    def visit_divide(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking
        raise TypeError, 'left node is not a int or float' unless left_primitive.is_a?(Primitives::Integer) || left_primitive.is_a?(Primitives::Float)
        raise TypeError, 'right node is not a int or float' unless right_primitive.is_a?(Primitives::Integer) || right_primitive.is_a?(Primitives::Float)

        #divide the two values
        result = left_primitive.raw_value / right_primitive.raw_value
        
        #return the result as a integer or float depending on the type of the result
        if left_primitive.is_a?(Primitives::Integer)
            Primitives::Integer.new(result)
        else
            #round to 3 decimal places
            result = result.round(3)
            Primitives::Float.new(result)
        end
    end

    def visit_modulo(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking
        raise TypeError, 'left node is not a int or float' unless left_primitive.is_a?(Primitives::Integer) || left_primitive.is_a?(Primitives::Float)
        raise TypeError, 'right node is not a int or float' unless right_primitive.is_a?(Primitives::Integer) || right_primitive.is_a?(Primitives::Float)

        #modulo the two values
        result = left_primitive.raw_value % right_primitive.raw_value

        #return the result as a integer or float depending on the type of the result
        if left_primitive.is_a?(Primitives::Integer)
            Primitives::Integer.new(result)
        else
            #round to 3 decimal places
            result = result.round(3)
            Primitives::Float.new(result)
        end
    end

    def visit_power(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking
        raise TypeError, 'left node is not a int or float' unless left_primitive.is_a?(Primitives::Integer) || left_primitive.is_a?(Primitives::Float)
        raise TypeError, 'right node is not a int or float' unless right_primitive.is_a?(Primitives::Integer) || right_primitive.is_a?(Primitives::Float)

        #power the two values
        result = left_primitive.raw_value ** right_primitive.raw_value

        #return the result as a integer or float depending on the type of the result
        if left_primitive.is_a?(Primitives::Integer)
            Primitives::Integer.new(result)
        else
            #round to 3 decimal places
            result = result.round(3)
            Primitives::Float.new(result)
        end
    end

    def visit_negation(node)
        #recurse subnodes to primitives
        value_primitive = node.value.visit(self)

        #type checking
        raise TypeError, 'value node is not a int or float' unless value_primitive.is_a?(Primitives::Integer) || value_primitive.is_a?(Primitives::Float)

        #negate the value
        result = -value_primitive.raw_value

        #return the result as a integer or float depending on the type of the result
        if value_primitive.is_a?(Primitives::Integer)
            Primitives::Integer.new(result)
        else
            #round to 3 decimal places
            result = result.round(3)
            Primitives::Float.new(result)
        end
    end

    def visit_exponent(node)
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)
    
        raise TypeError, 'left node is not a int or float' unless left_primitive.is_a?(Primitives::Integer) || left_primitive.is_a?(Primitives::Float)
        raise TypeError, 'right node is not a int or float' unless right_primitive.is_a?(Primitives::Integer) || right_primitive.is_a?(Primitives::Float)
    
        result = left_primitive.raw_value ** right_primitive.raw_value
    
        if left_primitive.is_a?(Primitives::Integer)
          Primitives::Integer.new(result)
        else
          result = result.round(3)
          Primitives::Float.new(result)
        end
    end

    #LOGICAL OPS
    def visit_and(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking
        raise TypeError, 'left node is not a boolean' unless left_primitive.is_a?(Primitives::Boolean)
        raise TypeError, 'right node is not a boolean' unless right_primitive.is_a?(Primitives::Boolean)

        #and the two values
        result = left_primitive.raw_value && right_primitive.raw_value

        #return the result
        Primitives::Boolean.new(result)
    end

    def visit_or(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking
        raise TypeError, 'left node is not a boolean' unless left_primitive.is_a?(Primitives::Boolean)
        raise TypeError, 'right node is not a boolean' unless right_primitive.is_a?(Primitives::Boolean)

        #or the two values
        result = left_primitive.raw_value || right_primitive.raw_value

        #return the result
        Primitives::Boolean.new(result)
    end

    def visit_not(node)
        #recurse subnodes to primitives
        value_primitive = node.node.visit(self)

        #type checking
        raise TypeError, 'value node is not a boolean' unless value_primitive.is_a?(Primitives::Boolean)

        #not the value
        result = !value_primitive.raw_value

        #return the result
        Primitives::Boolean.new(result)
    end

    #CELL VALS
    def visit_cell_left(node)
        row = node.row.raw_value
        column = node.column.raw_value

        #type checking
        raise TypeError, 'row is not a int' unless row.is_a?(Primitives::Integer)
        raise TypeError, 'column is not a int' unless column.is_a?(Primitives::Integer)

        #return the result
        Primitives::CellAddress.new(row, column)
    end

    def visit_cell_right(node)
        row = node.row.visit(self).raw_value
        col = node.column.visit(self).raw_value
        @runtime.get_cell(row, col) # Return the value of the referenced cell
    end

    #BITWISE
    def visit_bitwise_and(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking
        raise TypeError, 'left node is not a int' unless left_primitive.is_a?(Primitives::Integer)
        raise TypeError, 'right node is not a int' unless right_primitive.is_a?(Primitives::Integer)

        #and the two values
        result = left_primitive.raw_value & right_primitive.raw_value

        #return the result
        Primitives::Integer.new(result)
    end

    def visit_bitwise_or(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking
        raise TypeError, 'left node is not a int' unless left_primitive.is_a?(Primitives::Integer)
        raise TypeError, 'right node is not a int' unless right_primitive.is_a?(Primitives::Integer)

        #or the two values
        result = left_primitive.raw_value | right_primitive.raw_value

        #return the result
        Primitives::Integer.new(result)
    end

    def visit_bitwise_xor(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking
        raise TypeError, 'left node is not a int' unless left_primitive.is_a?(Primitives::Integer)
        raise TypeError, 'right node is not a int' unless right_primitive.is_a?(Primitives::Integer)

        #xor the two values
        result = left_primitive.raw_value ^ right_primitive.raw_value

        #return the result
        Primitives::Integer.new(result)
    end

    def visit_bitwise_not(node)
        #recurse subnodes to primitives
        value_primitive = node.node.visit(self)

        #type checking
        raise TypeError, 'value node is not a int' unless value_primitive.is_a?(Primitives::Integer)

        #not the value
        result = ~value_primitive.raw_value

        #return the result
        Primitives::Integer.new(result)
    end

    def visit_bitwise_left_shift(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking
        raise TypeError, 'left node is not a int' unless left_primitive.is_a?(Primitives::Integer)
        raise TypeError, 'right node is not a int' unless right_primitive.is_a?(Primitives::Integer)

        #left shift the two values
        result = left_primitive.raw_value << right_primitive.raw_value

        #return the result
        Primitives::Integer.new(result)
    end

    def visit_bitwise_right_shift(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking
        raise TypeError, 'left node is not a int' unless left_primitive.is_a?(Primitives::Integer)
        raise TypeError, 'right node is not a int' unless right_primitive.is_a?(Primitives::Integer)

        #right shift the two values
        result = left_primitive.raw_value >> right_primitive.raw_value

        #return the result as a integer or float depending on the type of the result
        if left_primitive.is_a?(Primitives::Integer)
            Primitives::Integer.new(result)
        else
            #round to 3 decimal places
            result = result.round(3)
            Primitives::Float.new(result)
        end
    end

    #RELATIONAL
    def visit_equal(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking for same class
        raise TypeError, 'left node is not the same class as right node' unless left_primitive.class == right_primitive.class

        #equal the two values
        result = left_primitive.raw_value == right_primitive.raw_value

        #return the result
        Primitives::Boolean.new(result)
    end

    def visit_not_equal(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking for same class
        raise TypeError, 'left node is not the same class as right node' unless left_primitive.class == right_primitive.class

        #not equal the two values
        result = left_primitive.raw_value != right_primitive.raw_value

        #return the result
        Primitives::Boolean.new(result)
    end

    def visit_less_than(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking for same class
        raise TypeError, 'left node is not the same class as right node' unless left_primitive.class == right_primitive.class

        #less than the two values
        result = left_primitive.raw_value < right_primitive.raw_value

        #return the result
        Primitives::Boolean.new(result)
    end

    def visit_less_than_or_equal(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking for same class
        raise TypeError, 'left node is not the same class as right node' unless left_primitive.class == right_primitive.class

        #less than or equal the two values
        result = left_primitive.raw_value <= right_primitive.raw_value

        #return the result
        Primitives::Boolean.new(result)
    end

    def visit_greater_than(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking for same class
        raise TypeError, 'left node is not the same class as right node' unless left_primitive.class == right_primitive.class

        #greater than the two values
        result = left_primitive.raw_value > right_primitive.raw_value

        #return the result
        Primitives::Boolean.new(result)
    end

    def visit_greater_than_or_equal(node)
        #recurse subnodes to primitives
        left_primitive = node.left_node.visit(self)
        right_primitive = node.right_node.visit(self)

        #type checking for same class
        raise TypeError, 'left node is not the same class as right node' unless left_primitive.class == right_primitive.class

        #greater than or equal the two values
        result = left_primitive.raw_value >= right_primitive.raw_value

        #return the result
        Primitives::Boolean.new(result)
    end

    #CASTING
    def visit_cast_to_int(node)
        #recurse subnodes to primitives
        value_primitive = node.node.visit(self)

        #type checking
        raise TypeError, 'value node is not a float' unless value_primitive.is_a?(Primitives::Float)

        #cast the value
        result = value_primitive.raw_value.to_i

        #return the result
        Primitives::Integer.new(result)
    end

    def visit_cast_to_float(node)
        #recurse subnodes to primitives
        value_primitive = node.node.visit(self)

        #type checking
        raise TypeError, 'value node is not a int' unless value_primitive.is_a?(Primitives::Integer)

        #cast the value
        result = value_primitive.raw_value.to_f

        #return the result
        Primitives::Float.new(result)
    end

    #STATISTICS
    def visit_max(node)
        #recurse subnodes to primitives
        # get each row and column
        top_l_row = node.left_node
        bottom_r_col = node.right_node

        # get list of all the cell values in range
        values = range_helper(top_l_row,bottom_r_col)

        #sum all the range values
        puts("VALUES:#{values}")
        result = 0.0
        values.each { |val| result += val.to_f }

        #get the max
        result = values.max
        puts("RESULT: #{result}")
        puts()

        #return the result
        Primitives::Float.new(result)
    end

    def visit_min(node)
        #recurse subnodes to primitives
        # get each row and column
        top_l_row = node.left_node
        bottom_r_col = node.right_node

        # get list of all the cell values in range
        values = range_helper(top_l_row,bottom_r_col)
        
        #sum all the range values
        puts("VALUES:#{values}")
        result = 0.0
        values.each { |val| result += val.to_f }

        #get the min
        result = values.min
        puts("RESULT: #{result}")
        puts()

        #return the result
        Primitives::Float.new(result)
    end

    def visit_mean(node)
        #recurse subnodes to primitives
        # get each row and column
        top_l_row = node.left_node
        bottom_r_col = node.right_node

        # get list of all the cell values in range
        values = range_helper(top_l_row,bottom_r_col)

        #sum all the range values
        puts("VALUES:#{values}")
        result = 0.0
        values.each { |val| result += val.to_f }

        #get the mean and round to the 3rd decimal
        result = result/values.length
        result = result.round(3)
        puts("RESULT: #{result}")
        puts()

        #return the result
        Primitives::Float.new(result)
    end

    def visit_sum(node)
        #recurse subnodes to primitives
        # get each row and column
        top_l_row = node.left_node
        bottom_r_col = node.right_node

        # get list of all the cell values in range
        values = range_helper(top_l_row,bottom_r_col)

        #sum all the range values
        puts("VALUES:#{values}")
        result = 0.0
        values.each { |val| result += val.to_f }
        result = result.round(3)
        puts("RESULT: #{result}")
        puts()

        #return the result
        Primitives::Float.new(result) 
    end

    def range_helper(top_left,bottom_right)
        # get range of rows
        rows = top_left.row.raw_value..bottom_right.row.raw_value 
        # get range of cols
        columns = top_left.column.raw_value..bottom_right.column.raw_value
        values = []
        
        rows.each do |row|
            columns.each do |col|
                # save each to list
                # puts("#{row},#{col}")
                # only add to list if there is a value
                # DO WE CARE WHAT TYPE IT IS? 
                #CAN WE SUM 5.0+3? 
                
                if @runtime.get_cell(row,col)!=nil
                    values.append(@runtime.get_cell(row,col).visit(self).raw_value)
                end
            end
        end
        # return list with all values
        values
    end
end