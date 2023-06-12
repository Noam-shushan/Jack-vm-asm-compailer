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
proc complie_expressionList { tokens_name indent_level } {
    upvar 1 $tokens_name tokens
    incr indent_level

    set expression [complie_expression tokens $indent_level]
    set output [new_node "<expressionList>\n" $expression $indent_level]

    set i 0
    foreach next_token $tokens {
        set label [dict get $next_token label]
        set token [dict get $next_token token]
        if { $label == "symbol" && $token == ";" } {
            break
        }
        if { $label == "symbol" && $token == "," && ($i % 2) == 0 } {
            set output [new_node $output "<symbol> $token </symbol>\n" $indent_level]
            set tokens [lrange $tokens 1 end]
        } elseif { $label == "identifier" && ($i % 2) == 1 } {
            set expression [complie_expression tokens $indent_level]
            set output [new_node $output $expression $indent_level]
        }
        incr i
    }

    set output [new_node $output "</expressionList>\n" [expr $indent_level - 1] ]
    return $output
}

# expression -> term (op term)*
proc complie_expression { tokens_name indent_level} {
    upvar 1 $tokens_name tokens
    incr indent_level

    # term
    set term [complie_term tokens $indent_level]
    if {$term == ""} {
        return ""
    }
    set output [new_node "<expression>\n" $term $indent_level]

    # (op term)*
    set i 0
    # TODO: got problem here, the tokens is not updated
    foreach next_token $tokens {
        set label [dict get $next_token label]
        set token [dict get $next_token token]
        puts "in (op term)*. token: $token, label: $label, i: $i"
        if { $label == "symbol" && ($token == ";" || $token == ")") } {
            puts "label: $label, token: $token // int expression foreach break"
            break
        }
        if { [is_oprator $token] && ($i % 2) == 0 } {
            set output [new_node $output "<symbol> $token </symbol>\n" $indent_level]
            set tokens [lrange $tokens 1 end]
            } elseif { ($label == "identifier"
                || ($label == "symbol" && $token == "("))
                && ($i % 2) == 1} {
                set term [complie_term tokens $indent_level]
                set output [new_node $output $term $indent_level]
            }
            incr i
        }

        set output [new_node $output "</expression>\n" [expr $indent_level - 1] ]

        return $output
    }

    # term -> integerConstant | stringConstant | keywordConstant
    #       | varName | varName "[" expression "]"
    #       | subroutineCall | "(" expression ")"
    #       | unaryOp term
    proc complie_term { tokens_name indent_level } {
        upvar 1 $tokens_name tokens
        incr indent_level

        set output "<term>\n"

        set next_token [lindex $tokens 0]
        set label [dict get $next_token label]
        set token [dict get $next_token token]

        #  integerConstant | stringConstant | keywordConstant
        if { $label == "integerConstant" } {
            set output [new_node $output "<integerConstant> $token </integerConstant>\n" $indent_level]
            set tokens [lrange $tokens 1 end]
            set output [new_node $output "</term>\n" [expr $indent_level - 1] ]
            return $output
        } elseif { $label == "stringConstant" } {
            set output [new_node $output "<stringConstant> $token </stringConstant>\n" $indent_level]
            set tokens [lrange $tokens 1 end]
            set output [new_node $output "</term>\n" [expr $indent_level - 1] ]
            return $output
        } elseif { $label == "keyword" && [is_keyword_constant $token] } {
            set output [new_node $output "<keyword> $token </keyword>\n" $indent_level]
            set tokens [lrange $tokens 1 end]
            set output [new_node $output "</term>\n" [expr $indent_level - 1] ]
            return $output
        }
        puts "in term the token is: $token"
        # "(" expression ")"
        if { $token == "(" } {
            # (
            set symbol [complie_symbol tokens "("]
            set output [new_node $output $symbol $indent_level]

            # expression
            set expression [complie_expression tokens $indent_level]
            set output [new_node $output $expression $indent_level]

            # )
            set symbol [complie_symbol tokens ")"]
            if { $symbol != "" } {
                set output [new_node $output $symbol $indent_level]
            } else {
                error "missing ) in term after expression"
            }


            set output [new_node $output "</term>\n" [expr $indent_level - 1] ]

            return $output
        }

        # unaryOp term
        if { [is_unary_oprator $token] } {
            # unaryOp
            set symbol [complie_symbol tokens $token]
            set output [new_node $output $symbol $indent_level]

            # term
            set term [complie_term tokens $indent_level]
            set output [new_node $output $term $indent_level]

            set output [new_node $output "</term>\n" [expr $indent_level - 1] ]
            return $output
        }

        # subroutineCall
        if { [is_subroutineCall $tokens] } {
            set subroutineCall [complie_subroutineCall tokens $indent_level]
            if { $subroutineCall != "" } {
                set output [new_node $output $subroutineCall $indent_level]

                set output [new_node $output "</term>\n" [expr $indent_level - 1] ]

                return $output
            }
        }

        # varName | varName "[" expression "]"
        if { $label == "identifier"} {
            # varName
            set output [new_node $output "<identifier> $token </identifier>\n" $indent_level]
            set tokens [lrange $tokens 1 end]

            set next_token [lindex $tokens 0]
            set label [dict get $next_token label]
            set token [dict get $next_token token]
            # varName "[" expression "]"
            if { $token == "\[" } {
                # [
                set symbol [complie_symbol tokens "\["]
                set output [new_node $output $symbol $indent_level]

                puts "output: $output // varName \[ expression \] in term"

                # expression
                set expression [complie_expression tokens $indent_level]
                set output [new_node $output $expression $indent_level]

                # ]
                set symbol [complie_symbol tokens "\]"]
                set output [new_node $output $symbol $indent_level]
            }
            set output [new_node $output "</term>\n" [expr $indent_level - 1] ]
            return $output
        }
        return ""
    }

    # subroutineCall -> subroutineName "(" expressionList ")"
    # | (className | varName) "." subroutineName "(" expressionList ")"
    proc complie_subroutineCall { tokens_name indent_level } {
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
                set output [new_node "" "<identifier> $next_token </identifier>\n" $indent_level]
                set tokens [lrange $tokens 1 end]
                set symbol [complie_symbol tokens "."]
                set output [new_node $output $symbol $indent_level]

                # subroutineName
                set subroutine_name [lindex $tokens 0]
                set subroutine_name_token [dict get $subroutine_name token]
                set subroutine_name_label [dict get $subroutine_name label]
                if { $subroutine_name_label == "identifier" && [is_valid_identifier $subroutine_name_token] } {
                    set output [new_node $output "<identifier> $subroutine_name_token </identifier>\n" $indent_level]
                    set tokens [lrange $tokens 1 end]
                }

                # "(" expressionList ")"
                set symbol [complie_symbol tokens "("]
                set output [new_node $output $symbol $indent_level]

                set expressionList [complie_expressionList tokens $indent_level]
                set output [new_node $output $expressionList $indent_level]

                set symbol [complie_symbol tokens ")"]
                set output [new_node $output $symbol $indent_level]
            } elseif { $second_token != "\[" } {
                # subroutineName
                if { $next_label == "identifier" && [is_valid_identifier $next_token] } {
                    set output [new_node $output "<identifier> $next_token </identifier>\n" $indent_level]
                    set tokens [lrange $tokens 1 end]
                }

                # "(" expressionList ")"
                set symbol [complie_symbol tokens "("]
                if { $symbol != "" } {
                    set output [new_node $output $symbol $indent_level]
                } else {
                    error "missing (. // in subroutineCall '(expressionList)'"
                }

                set expressionList [complie_expressionList tokens $indent_level]
                set output [new_node $output $expressionList $indent_level]

                set symbol [complie_symbol tokens ")"]
                if { $symbol != "" } {
                    set output [new_node $output $symbol $indent_level]
                } else {
                    error "missing ). // in subroutineCall '(expressionList)'"
                }
            }
        }

        return $output
    }
