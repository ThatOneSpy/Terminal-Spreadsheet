# five or more levels of precedence
# starting non terminal is expression
# expands directly to non-terminal (lvl0) for ops at top
# non terminal leads to non-terminal of next precedence
# levelN includes primitives,cell l and r vals, parenthesis expression, stat functions
# grammar should include all operators that have models 

<!-- top level logical (OR AND) -->
expression = expression && level0
           | expression || level0
           | level0
<!-- bitwise (OR, XOR, AND) -->
level0 = level0 | level1
       | level0 ^ level1
       | level0 & level1
       | level1
<!-- equality -->
level1 = level1 == level2
       | level1 != level2
       | level2
<!-- relational operators -->
level2 = level2 ‹ level3
       | level2 <= level3
       | level2 > level3 
       | level2 >= level 
       | level3
<!-- bitwise shift ops -->
level3 = level3 << level4
       | level3 >> level4 
       | level4
<!-- add and sub -->
level4 = level4 + level5
       | level4 - level5
       | level5
<!-- mult, div, mod -->
level5 = level5 * level6
       | level5 / level6
       | level5 % level6
       | level6
<!-- neg, and NOT's -->
level6 = -level7
       | !level7
       | ~level7
       | level7
<!-- exponents -->
level7 = level7 ** level8
       | level7
<!-- parenthesis, type cast, array, funcs -->
level8 = (expression)
        | (float) expression 
        | (int) expression
        | #[expression, expression] 
        | [expression, expression]
        | sum(expression, expression)
        | min(expression, expression)
        | max (expression, expression) 
        | mean (expression, expression)
        | PRIMITIVE
<!-- conditions  -->
level9 = if expression else expression end
