
set TYPES [list "int" "char" "boolean" "void"]
proc is_type {type} {
    global TYPES
    return [expr [lsearch -exact $TYPES $type] != -1]
}

set SUBROUTINE_TOKENS [list "function" "method" "constructor" ]
proc is_subroutine {token} {
    global SUBROUTINE_TOKENS
    return [expr [lsearch -exact $SUBROUTINE_TOKENS $token] != -1]
}

proc is_valid_identifier {identifier} {
    return [regexp {^[a-zA-Z_][a-zA-Z0-9_]*$} $identifier]
}

set OPERATORS [list "+" "-" "*" "/" "&amp;" "|" "&lt;" "&gt;" "="]
proc is_oprator {token} {
    global OPERATORS
    return [expr [lsearch -exact $OPERATORS $token] != -1]
}

set UNARY_OPERATORS [list "-" "~" ]
proc is_unary_oprator {token} {
    global UNARY_OPERATORS
    return [expr [lsearch -exact $UNARY_OPERATORS $token] != -1]
}

set KEYWORD_CONTANS [list "true" "false"  "null" "this"]
proc is_keyword_constant {token} {
    global KEYWORD_CONTANS
    return [expr [lsearch -exact $KEYWORD_CONTANS $token] != -1]
}

proc new_node { old_xml new_xml indent_level } {
    set base_space "  "
    set space [string repeat $base_space $indent_level]
    return "$old_xml$space$new_xml"
}

proc is_subroutineCall { tokens } {
    set first [lindex $tokens 0]
    set next_label [dict get $first label]
    set next_token [dict get $first token]

    set second [lindex $tokens 1]
    set second_token [dict get $second token]
    set second_label [dict get $second label]

    if { $next_label == "identifier" && $second_label == "symbol" && $second_token == "(" } {
        return 1
    } elseif { $next_label == "identifier" && $second_label == "symbol" && $second_token == "." } {
        return 1
    } else {
        return 0
    }
}

set TERM_START [list "(" "~" "-" ]
set TERM_LABELS [list "integerConstant" "stringConstant" "identifier" "keyword" ]
proc is_term_start { label token } {
    global TERM_START
    global TERM_LABELS
    if { [expr [lsearch -exact $TERM_START $token] != -1] && $label == "symbol" } {
        return 1
    } elseif { [expr [lsearch -exact $TERM_LABELS $label] != -1] } {
        return 1
    } else {
        return 0
    }
}


set START_EXP [list "(" "\[" "=" ]
proc is_expression_start { label token } {
    global START_EXP
    if { [expr [lsearch -exact $START_EXP $token] != -1] && $label == "symbol" } {
        return 1
    } elseif { $label == "integerConstant" || $label == "stringConstant" || $label == "identifier" || $label == "keyword" } {
        return 1
    } else {
        return 0
    }
}

set TERMINATING_EXP [list ";" "," "]" ")"]
proc is_expression_terminate { token } {
    global TERMINATING_EXP
    return [expr [lsearch -exact $TERMINATING_EXP $token] != -1]
}

