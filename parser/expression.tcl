# Expression:
# expression -> term (op term)*
# term -> integerConstant | stringConstant | keywordConstant | varName | varName "[" expression "]" | subroutineCall | "(" expression ")" | unaryOp term
# subroutineCall -> subroutineName "(" expressionList ")" | (className | varName) "." subroutineName "(" expressionList ")"
# expressionList -> (expression ("," expression)* )?
# keywordConstant -> "true" | "false" | "null" | "this"
# op -> "+" | "-" | "*" | "/" | "&amp;" | "|" | "&lt;" | "&gt;" | "="
# unaryOp -> "-" | "~"

source "helper_func.tcl"
source "symbols.tcl"

# expressionList -> (expression ("," expression)* )?
proc complie_expressionList { tokens } {

}

# expression -> term (op term)*
proc complie_expression { tokens_name } {
    upvar 1 $tokens_name tokens

    set output "<expression>\n"
    
    # term
    set term [complie_term tokens]
    set output "$output\t$term"

    # (op term)*
    set i 0
    foreach next_token $tokens {
        set label [dict get $next_token label]
        set token [dict get $next_token token]
        if { $label == "symbol" && $token == ";" } {
            break
        }
        if { [is_oprator $token] && [expr($i % 2) == 0] } {
            set output "$output\t<symbol>$token</symbol>\n"
            set tokens [lrange $tokens 1 end]
        } elseif { $label == "identifier" && [expr($i % 2) == 1] } {
            set term [complie_term tokens]
            set output "$output\t$term"
        }
        incr i
    }

    set output "$output</expression>\n"
    return $output
}

# term -> integerConstant | stringConstant | keywordConstant   
#       | varName | varName "[" expression "]"
#       | subroutineCall | "(" expression ")"
#       | unaryOp term
proc complie_term { tokens_name } {
    upvar 1 $tokens_name tokens

    set output "<term>\n"

    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    # varName | varName "[" expression "]"
    if { $label == "identifier"} {
        # varName
        set output "$output\t<identifier>$token</identifier>\n"
        set tokens [lrange $tokens 1 end]
        
        set next_token [lindex $tokens 0]
        set label [dict get $next_token label]
        set token [dict get $next_token token]
        # varName "[" expression "]"
        if { $token == "\[" } {
            # [
            set symbol [complie_symbol tokens "\["]
            set output "$output\t$symbol"

            # expression
            set expression [complie_expression tokens]
            set output "$output\t$expression"

            # ]
            set symbol [complie_symbol tokens "\]"]
            set output "$output\t$symbol"
        }
    }

    if { $label == "integerConstant" } {
        set output "$output\t<integerConstant>$token</integerConstant>\n"
        set tokens [lrange $tokens 1 end]
    } elseif { $label == "stringConstant" } {
        set output "$output\t<stringConstant>$token</stringConstant>\n"
        set tokens [lrange $tokens 1 end]
    } elseif { $label == "keyword" && [is_keyword_constant] $token } {
        set output "$output\t<keyword>$token</keyword>\n"
        set tokens [lrange $tokens 1 end]
    }

    set output "$output</term>\n"
    return $output
}

# subroutineCall -> subroutineName "(" expressionList ")" 
# | (className | varName) "." subroutineName "(" expressionList ")"
proc complie_subroutineCall { tokens } {

}
