# Statements:
# statement -> letStatement | ifStatement | whileStatement | doStatement | returnStatement
# statements -> statement*
# ifStatement -> "if" "(" expression ")" "{" statements "}" ("else" "{" statements "}")?
# whileStatement -> "while" "(" expression ")" "{" statements "}"
# letStatement -> "let" varName ("[" expression "]")? "=" expression ";"
# doStatement -> "do" subroutineCall ";"
# returnStatement -> "return" expression? ";"

source "symbols.tcl"
source "expressions.tcl"

proc complie_statements { tokens_name } {
    upvar 1 $tokens_name tokens
    
    set output "<statements>\n"
    set statement [complie_statement tokens]
    while { statement != "" } {
        set output "$output\t$statement"
        set statement [complie_statement tokens]
    }
    set output "$output</statements>\n"
    return $statements
}

proc complie_statement { tokens_name } {
    upvar 1 $tokens_name tokens

    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "keyword" } {
        switch $token {
            "let" {
                return [complie_letStatement tokens]
            }
            "if" {
                return [complie_ifStatement tokens]
            }
            "while" {
                return [complie_whileStatement tokens]
            }
            "do" {
                return [complie_doStatement tokens]
            }
            "return" {
                return [complie_returnStatement tokens]
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
proc complie_letStatement { tokens_name } {
    upvar 1 $tokens_name tokens

    # let
    set output "<letStatement>\n\t<keyword>let</keyword>\n"
    set tokens [lrange $tokens 1 end]
    
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    # varName 
    if { $label == "identifier" && [is_valid_identifier] $token } {
        set output "$output\t<identifier>$token</identifier>\n"
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
        set output "$output\t<symbol>\[</symbol>\n"
        set tokens [lrange $tokens 1 end]
        
        # expression
        set expression [complie_expression tokens]
        set output "$output\t$expression"
        
        # ]
        set symbol [complie_symbol tokens "]"]
        if { $symbol != "" } {
            set output "$output\t$symbol"
        } else {
            error "invalid statement missing ]"
        }
    }

    # =
    set symbol [complie_symbol tokens "="]
    if { $symbol != "" } {
        set output "$output\t$symbol"
    } else {
        error "invalid statement missing ="
    }
    
    # expression
    set expression [complie_expression tokens]
    set output "$output\t$expression"
    
    # ;
    set symbol [complie_symbol tokens ";"]
    if { $symbol != "" } {
        set output "$output\t$symbol"
    } else {
        error "invalid statement missing ;"
    }

    set output "$output</letStatement>\n"
    return $output
}

# ifStatement -> "if" "(" expression ")" "{" statements "}" ("else" "{" statements "}")?
proc complie_ifStatement { tokens_name } {
    upvar 1 $tokens_name tokens

    set output "<ifStatement>\n\t<keyword>if</keyword>\n"
    set tokens [lrange $tokens 1 end]

    # (
    set symbol [complie_symbol tokens "("]
    if { $symbol != "" } {
        set output "$output\t$symbol"
    } else {
        error "invalid statement missing ("
    }

    # expression
    set expression [complie_expression tokens]
    set output "$output\t$expression"
    
    # )
    set symbol [complie_symbol tokens ")"]
    if { $symbol != "" } {
        set output "$output\t$symbol"
    } else {
        error "invalid statement missing )"
    }
    
    # {
    set symbol [complie_symbol tokens "{"]
    if { $symbol != "" } {
        set output "$output\t$symbol"
    } else {
        error "invalid statement missing {"
    }
    
    # statements
    set statements [complie_statements tokens]
    set output "$output\t$statements"
    
    # }
    set symbol [complie_symbol tokens "}"]
    if { $symbol != "" } {
        set output "$output\t$symbol"
    } else {
        error "invalid statement missing }"
    }
    # ("else" "{" statements "}")?
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "keyword" && $token == "else" } {
        set output "$output\t<keyword>else</keyword>\n"
        set tokens [lrange $tokens 1 end]
        # {
        set symbol [complie_symbol tokens "{"]
        if { $symbol != "" } {
            set output "$output\t$symbol"
        } else {
            error "invalid statement missing {"
        }
        # statements
        set statements [complie_statements tokens]
        set output "$output\t$statements"
        # }
        set symbol [complie_symbol tokens "}"]
        if { $symbol != "" } {
            set output "$output\t$symbol"
        } else {
            error "invalid statement missing }"
        }
    }
    set output "$output</ifStatement>\n"
    return $output
}

# whileStatement -> "while" "(" expression ")" "{" statements "}"
proc complie_whileStatement { tokens_name } {
    upvar 1 $tokens_name tokens

    set output "<whileStatement>\n\t<keyword>while</keyword>\n"
    set tokens [lrange $tokens 1 end]

    # (
    set symbol [complie_symbol tokens "("]
    if { $symbol != "" } {
        set output "$output\t$symbol"
    } else {
        error "invalid statement missing (, in statements.tcl in complie_whileStatement"
    }
    # expression
    set expression [complie_expression tokens]
    set output "$output\t$expression"
    # )
    set symbol [complie_symbol tokens ")"]
    if { $symbol != "" } {
        set output "$output\t$symbol"
    } else {
        error "invalid statement missing ). in statements.tcl in complie_whileStatement"
    }
    # {
    set symbol [complie_symbol tokens "{"]
    if { $symbol != "" } {
        set output "$output\t$symbol"
    } else {
        error "invalid statement missing {. in statements.tcl in complie_whileStatement"
    }
    # statements
    set statements [complie_statements tokens]
    set output "$output\t$statements"
    # }
    set symbol [complie_symbol tokens "}"]
    if { $symbol != "" } {
        set output "$output\t$symbol"
    } else {
        error "invalid statement missing }. in statements.tcl in complie_whileStatement"
    }
    set output "$output</whileStatement>\n"
    return $output
}

# doStatement -> "do" subroutineCall ";"
proc complie_doStatement { tokens_name } {
    upvar 1 $tokens_name tokens

    set output "<doStatement>\n\t<keyword>do</keyword>\n"
    set tokens [lrange $tokens 1 end]

    # subroutineCall
    set subroutineCall [complie_subroutineCall tokens]
    set output "$output\t$subroutineCall"
    # ;
    set symbol [complie_symbol tokens ";"]
    if { $symbol != "" } {
        set output "$output\t$symbol"
    } else {
        error "invalid statement missing ; in statements.tcl in complie_doStatement"
    }
    set output "$output</doStatement>\n"
    return $output
}

# returnStatement -> "return" expression? ";"
proc complie_returnStatement { tokens_name } {
    upvar 1 $tokens_name tokens

    set output "<returnStatement>\n\t<keyword>return</keyword>\n"
    set tokens [lrange $tokens 1 end]

    # expression?
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "symbol" && $token == ";" } {
        set output "$output\t<symbol>;</symbol>\n"
        set tokens [lrange $tokens 1 end]
    } else {
        set expression [complie_expression tokens]
        set output "$output\t$expression"
        # ;
        set symbol [complie_symbol tokens ";"]
        if { $symbol != "" } {
            set output "$output\t$symbol"
        } else {
            error "invalid statement missing ; in statements.tcl in complie_returnStatement"
        }
    }
    set output "$output</returnStatement>\n"
    return $output
}
