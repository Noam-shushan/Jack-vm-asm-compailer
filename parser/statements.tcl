# Statements:
# statement -> letStatement | ifStatement | whileStatement | doStatement | returnStatement
# statements -> statement*
# ifStatement -> "if" "(" expression ")" "{" statements "}" ("else" "{" statements "}")?
# whileStatement -> "while" "(" expression ")" "{" statements "}"
# letStatement -> "let" varName ("[" expression "]")? "=" expression ";"
# doStatement -> "do" subroutineCall ";"
# returnStatement -> "return" expression? ";"
source [file join [file dirname [info script]] "symbols.tcl"]
source [file join [file dirname [info script]] "expression.tcl"]

proc complie_statements { tokens_name indent_level } {
    upvar 1 $tokens_name tokens
    incr indent_level

    set output "<statements>\n"
    set statement [complie_statement tokens $indent_level]
    while { $statement != "" } {
        set output [new_node $output  $statement $indent_level]
        set statement [complie_statement tokens $indent_level]
    }

    set output [new_node $output "</statements>\n" [expr $indent_level - 1] ]

    return $output
}

proc complie_statement { tokens_name indent_level } {
    upvar 1 $tokens_name tokens

    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]

    if { $label == "keyword" } {
        switch $token {
            "let" {
                return [complie_letStatement tokens $indent_level]
            }
            "if" {
                return [complie_ifStatement tokens $indent_level]
            }
            "while" {
                return [complie_whileStatement tokens $indent_level]
            }
            "do" {
                return [complie_doStatement tokens $indent_level]
            }
            "return" {
                return [complie_returnStatement tokens $indent_level]
            }
            default {
                return ""
            }
        }
    } else {
        return ""
    }
}

# letStatement -> "let" varName ("[" expression "]")? "=" expression ";"
proc complie_letStatement { tokens_name indent_level} {
    upvar 1 $tokens_name tokens
    incr indent_level
    # let
    set output [new_node "<letStatement>\n" "<keyword> let </keyword>\n" $indent_level]
    set tokens [lrange $tokens 1 end]

    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]

    # varName
    if { $label == "identifier" && [is_valid_identifier $token] } {
        set output [new_node $output "<identifier> $token </identifier>\n" $indent_level]
        set tokens [lrange $tokens 1 end]
    } else {
        error "invalid varName"
    }

    # ("[" expression "]")?
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "symbol" && $token == "\[" } {
        # [
        set output [new_node $output "<symbol> \[ </symbol>\n" $indent_level]
        set tokens [lrange $tokens 1 end]

        # expression
        set expression [complie_expression tokens $indent_level]
        set output [new_node $output $expression $indent_level]

        # ]
        set symbol [complie_symbol tokens "]"]
        if { $symbol != "" } {
            set output [new_node $output $symbol $indent_level]
        } else {
            error "invalid statement missing ]"
        }
    }

    # =
    set symbol [complie_symbol tokens "="]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing ="
    }

    # expression
    set expression [complie_expression tokens $indent_level]
    set output [new_node $output $expression $indent_level]

    # ;
    set symbol [complie_symbol tokens ";"]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing ;"
    }

    set output [new_node $output "</letStatement>\n" [expr $indent_level - 1] ]
    return $output
}

# ifStatement -> "if" "(" expression ")" "{" statements "}" ("else" "{" statements "}")?
proc complie_ifStatement { tokens_name indent_level } {
    upvar 1 $tokens_name tokens
    incr indent_level

    set output [new_node "<ifStatement>\n"  "<keyword> if </keyword>\n" $indent_level]
    set tokens [lrange $tokens 1 end]

    # (
    set symbol [complie_symbol tokens "("]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing (. in complie_ifStatement"
    }

    # expression
    set expression [complie_expression tokens $indent_level]
    set output [new_node $output $expression $indent_level]

    # )
    set symbol [complie_symbol tokens ")"]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing )"
    }

    # {
    set symbol [complie_symbol tokens "\{"]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing \{"
    }

    # statements
    set statements [complie_statements tokens $indent_level]
    set output [new_node $output $statements $indent_level]

    # }
    set symbol [complie_symbol tokens "\}"]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing \}"
    }

    # ("else" "{" statements "}")?
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "keyword" && $token == "else" } {
        set output [new_node $output "<keyword> else </keyword>\n" $indent_level]
        set tokens [lrange $tokens 1 end]
        # {
        set symbol [complie_symbol tokens "\{"]
        if { $symbol != "" } {
            set output [new_node $output $symbol $indent_level]
        } else {
            error "invalid statement missing \{"
        }

        # statements
        set statements [complie_statements tokens $indent_level]
        set output [new_node $output $statements $indent_level]
        # }
        set symbol [complie_symbol tokens "\}"]
        if { $symbol != "" } {
            set output [new_node $output $symbol $indent_level]
        } else {
            error "invalid statement missing \}"
        }
    }

    set output [new_node $output "</ifStatement>\n" [expr $indent_level - 1] ]

    return $output
}

# whileStatement -> "while" "(" expression ")" "{" statements "}"
proc complie_whileStatement { tokens_name indent_level } {
    upvar 1 $tokens_name tokens
    incr indent_level

    set output [new_node "<whileStatement>\n" "<keyword> while </keyword>\n" $indent_level]
    set tokens [lrange $tokens 1 end]

    # (
    set symbol [complie_symbol tokens "("]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing (, in statements.tcl in complie_whileStatement"
    }

    # expression
    set expression [complie_expression tokens $indent_level]
    set output [new_node $output $expression $indent_level]

    # )
    set symbol [complie_symbol tokens ")"]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing ). in statements.tcl in complie_whileStatement"
    }

    # {
    set symbol [complie_symbol tokens "\{"]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing \{. in statements.tcl in complie_whileStatement"
    }

    # statements
    set statements [complie_statements tokens $indent_level]
    set output [new_node $output $statements $indent_level]

    # }
    set symbol [complie_symbol tokens "\}"]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing \}. in statements.tcl in complie_whileStatement"
    }

    set output [new_node $output "</whileStatement>\n" [expr $indent_level - 1] ]

    return $output
}

# doStatement -> "do" subroutineCall ";"
proc complie_doStatement { tokens_name indent_level } {
    upvar 1 $tokens_name tokens
    incr indent_level

    set output [new_node "<doStatement>\n" "<keyword> do </keyword>\n" $indent_level]
    set tokens [lrange $tokens 1 end]

    # subroutineCall
    if { [is_subroutineCall $tokens] } {
        set subroutineCall [complie_subroutineCall tokens $indent_level]
        set output [new_node $output $subroutineCall $indent_level]
    } else {
        error "invalid statement missing subroutineCall in statements.tcl in complie_doStatement"
    }

    # ;
    set symbol [complie_symbol tokens ";"]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing ; in statements.tcl in complie_doStatement"
    }

    set output [new_node $output "</doStatement>\n" [expr $indent_level - 1] ]

    return $output
}

# returnStatement -> "return" expression? ";"
proc complie_returnStatement { tokens_name indent_level } {
    upvar 1 $tokens_name tokens
    incr indent_level

    set output [new_node "<returnStatement>\n" "<keyword> return </keyword>\n" $indent_level]
    set tokens [lrange $tokens 1 end]

    # expression?
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "symbol" && $token == ";" } {
        set output [new_node $output "<symbol> ; </symbol>\n" $indent_level]
        set tokens [lrange $tokens 1 end]
    } else {
        set expression [complie_expression tokens $indent_level]
        set output [new_node $output $expression $indent_level]

        # ;
        set symbol [complie_symbol tokens ";"]
        if { $symbol != "" } {
            set output [new_node $output $symbol $indent_level]
        } else {
            error "invalid statement missing ; in statements.tcl in complie_returnStatement"
        }
    }

    set output [new_node $output "</returnStatement>\n" [expr $indent_level - 1] ]
    return $output
}
