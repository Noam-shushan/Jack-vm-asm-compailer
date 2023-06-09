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
    upvar 1 $tokens_name tokens

    set output "<expressionList>\n"
    set expression [complie_expression tokens]
    set output "$output  $expression"

    set i 0
    foreach next_token $tokens {
        set label [dict get $next_token label]
        set token [dict get $next_token token]
        if { $label == "symbol" && $token == ";" } {
            break
        }
        if { $label == "symbol" && $token == "," && ($i % 2) == 0 } {
            set output "$output  <symbol> $token </symbol>\n"
            set tokens [lrange $tokens 1 end]
        } elseif { $label == "identifier" && ($i % 2) == 1 } {
            set expression [complie_expression tokens]
            set output "$output  $expression"
        }
        incr i
    }

    set output "$output</expressionList>\n"
    return $output
}

# expression -> term (op term)*
proc complie_expression { tokens_name } {
    upvar 1 $tokens_name tokens

    set output "<expression>\n"
    
    # term
    set term [complie_term tokens]
    set output "$output  $term"

    # (op term)*
    set i 0
    foreach next_token $tokens {
        set label [dict get $next_token label]
        set token [dict get $next_token token]
        if { $label == "symbol" && $token == ";" } {
            break
        }
        if { [is_oprator $token] && ($i % 2) == 0 } {
            set output "$output  <symbol> $token </symbol>\n"
            set tokens [lrange $tokens 1 end]
        } elseif { $label == "identifier" && ($i % 2) == 1 } {
            set term [complie_term tokens]
            set output "$output  $term"
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

    #  integerConstant | stringConstant | keywordConstant 
    if { $label == "integerConstant" } {
        set output "$output  <integerConstant> $token </integerConstant>\n"
        set tokens [lrange $tokens 1 end]
        set output "$output</term>\n"
        return $output
    } elseif { $label == "stringConstant" } {
        set output "$output  <stringConstant> $token </stringConstant>\n"
        set tokens [lrange $tokens 1 end]
        set output "$output</term>\n"
        return $output
    } elseif { $label == "keyword" && [is_keyword_constant $token] } {
        set output "$output  <keyword> $token </keyword>\n"
        set tokens [lrange $tokens 1 end]
        set output "$output</term>\n"
        return $output
    }

    # "(" expression ")"
    if { $token == "\(" } {
        # (
        set symbol [complie_symbol tokens "\("]
        set output "$output  $symbol"

        # expression
        set expression [complie_expression tokens]
        set output "$output  $expression"

        # )
        set symbol [complie_symbol tokens "\)"]
        set output "$output  $symbol"
        set output "$output</term>\n"
        return $output
    }

    # unaryOp term
    if { [is_unary_oprator $token] } {
        # unaryOp
        set symbol [complie_symbol tokens $token]
        set output "$output  $symbol"

        # term
        set term [complie_term tokens]
        set output "$output  $term"
        set output "$output</term>\n"
        return $output
    }

    # subroutineCall
    set subroutineCall [complie_subroutineCall tokens]
    if { $subroutineCall != "" } {
        set output "$output  $subroutineCall"
        set output "$output</term>\n"
        return $output
    }

    # varName | varName "[" expression "]"
    if { $label == "identifier"} {
        # varName
        set output "$output  <identifier> $token </identifier>\n"
        set tokens [lrange $tokens 1 end]
        
        set next_token [lindex $tokens 0]
        set label [dict get $next_token label]
        set token [dict get $next_token token]
        # varName "[" expression "]"
        if { $token == "\[" } {
            # [
            set symbol [complie_symbol tokens "\["]
            set output "$output  $symbol"

            # expression
            set expression [complie_expression tokens]
            set output "$output  $expression"

            # ]
            set symbol [complie_symbol tokens "\]"]
            set output "$output  $symbol"
        }
    }

    set output "$output</term>\n"
    return $output
}

# subroutineCall -> subroutineName "(" expressionList ")" 
# | (className | varName) "." subroutineName "(" expressionList ")"
proc complie_subroutineCall { tokens_name } {
    upvar 1 $tokens_name tokens
    set output ""

    set first [lindex $tokens 0]
    set next_label [dict get $first label]
    set next_token [dict get $first token]
    puts "next_token: $next_token next_label: $next_label // in complie_subroutineCall"

    set second [lindex $tokens 1]
    set second_token [dict get $second token]
    set second_label [dict get $second label]
    puts "second_token: $second_token second_label: $second_label // in complie_subroutineCall"

    # (className | varName) "." subroutineName "(" expressionList ")"
    if { $next_label == "identifier" } {
        if { $second_label == "symbol" && $second_token == "." } {
            # (className | varName) "." 
            set output "$output  <identifier> $next_token </identifier>\n"
            set tokens [lrange $tokens 1 end]
            set symbol [complie_symbol tokens "."]
            set output "$output  $symbol"
            
            # subroutineName 
            set subroutine_name [lindex $tokens 0]
            set subroutine_name_token [dict get $subroutine_name token]
            set subroutine_name_label [dict get $subroutine_name label]
            if { $subroutine_name_label == "identifier" && [is_valid_identifier $subroutine_name_token] } {
                set output "$output  <identifier> $subroutine_name_token </identifier>\n"
                set tokens [lrange $tokens 1 end]
            }
            
            # "(" expressionList ")"
            set symbol [complie_symbol tokens "("]
            set output "$output  $symbol"
            set expressionList [complie_expressionList tokens]
            set output "$output  $expressionList"
            set symbol [complie_symbol tokens ")"]
            set output "$output  $symbol"
        } else {
            # subroutineName 
            set subroutine_name [lindex $tokens 0]
            set subroutine_name_token [dict get $subroutine_name token]
            set subroutine_name_label [dict get $subroutine_name label]
            if { $subroutine_name_label == "identifier" && [is_valid_identifier $subroutine_name_token] } {
                set output "$output  <identifier> $subroutine_name_token </identifier>\n"
                set tokens [lrange $tokens 1 end]
            }

            # "(" expressionList ")"
            set symbol [complie_symbol tokens "("]
            set output "$output  $symbol"
            set expressionList [complie_expressionList tokens]
            set output "$output  $expressionList"
            set symbol [complie_symbol tokens ")"]
            set output "$output  $symbol"
        }
    }

    return $output
}
