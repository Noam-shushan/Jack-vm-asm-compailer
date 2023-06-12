# Program Structure:
# class -> "class" className "{" classVarDec* subroutineDec* "}"
# classVarDec -> ("static" | "field") type varName ("," varName)* ";"
# subroutineDec -> ("constructor" | "function" | "method") ("void" | type) subroutineName "(" parameterList ")" subroutineBody
# parameterList -> (type varName ("," type varName)*)?
# subroutineBody -> "{" varDec* statements "}"
# varDec -> "var" type varName ("," varName)* ";"
# type -> "int" | "void" | "boolean" | className
# className -> identifier
# subroutineName -> identifier
# varName -> identifier

source "helper_func.tcl"
source "symbols.tcl"
source "statements.tcl"

# class -> "class" className "{" classVarDec* subroutineDec* "}"
proc complie_class { tokens_name } {
    upvar 1 $tokens_name tokens

    set indent_level 1

    set output ""
    # class
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "keyword" && $token == "class" } {
        set output [new_node "<class>\n" "<keyword> class </keyword>\n" $indent_level]
        set tokens [lrange $tokens 1 end]
    } else {
        error "ERROR: expected class. in complie_class"
    }

    # className
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set identifier [dict get $next_token token]
    if { $label == "identifier" } {
        set output [new_node $output "<identifier> $identifier </identifier>\n" $indent_level]
        set tokens [lrange $tokens 1 end]
    } else {
        error "ERROR: expected class name. in complie_class"
    }

    # {
    set symbol [complie_symbol tokens "\{"]
    puts "symbol: $symbol"
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing '\{'. in complie_class"
    }
    puts "output:\n$output"
    set next_token [lindex $tokens 0]

    # classVarDec*
    set class_var_dec [complie_classVarDec tokens $indent_level]
    while { $class_var_dec != "" } {
        set output [new_node $output $class_var_dec $indent_level]
        set class_var_dec [complie_classVarDec tokens $indent_level]
    }
    puts "output:\n$output // after complie_classVarDec"

    # subroutineDec*
    set subroutine [complie_subroutine tokens $indent_level]
    while { $subroutine != "" } {
        set output [new_node $output $subroutine $indent_level]
        puts "output:\n$output // while complie_subroutine"
        set subroutine [complie_subroutine tokens $indent_level]
    }
    puts "output:\n$output // after complie_subroutine"

    # }
    set symbol [complie_symbol tokens "\}"]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing \}. in complie_class"
    }
    set output [new_node $output "</class>\n" [expr $indent_level - 1]]
    return $output
}

# classVarDec -> ("static" | "field") type varName ("," varName)* ";"
proc complie_classVarDec { tokens_name indent_level } {
    upvar 1 $tokens_name tokens

    incr indent_level
    set output ""
    # static or field
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "keyword"
        && [expr { $token == "static" || $token == "field"}] } {
        set output [new_node "<classVarDec>\n" "<keyword> $token </keyword>\n" $indent_level]
        set tokens [lrange $tokens 1 end]
    } else {
        return ""
    }


    # type
    set type [complie_type tokens]
    set output [new_node $output $type $indent_level]

    # varName
    set i 0
    foreach ntoken $tokens {
        set label [dict get $ntoken label]
        set token [dict get $ntoken token]
        if { $label == "identifier" && ($i % 2) == 0 } {
            set output [new_node $output "<identifier> $token </identifier>\n" $indent_level]
            set tokens [lrange $tokens 1 end]
        } elseif { $label == "symbol" && $token == "," && ($i % 2) == 1 } {
            set output [new_node $output "<symbol> , </symbol>\n" $indent_level]
            set tokens [lrange $tokens 1 end]
        } else {
            break
        }
        incr i
    }
    # ;
    set symbol [complie_symbol tokens ";"]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing ;. in complie_classVarDec"
    }
    set output [new_node $output "</classVarDec>\n" [expr $indent_level - 1]]
    return $output
}

# subroutineDec -> ("constructor" | "function" | "method")
#                  ("void" | type) subroutineName
#                  "(" parameterList ")" subroutineBody
proc complie_subroutine { tokens_name indent_level } {
    upvar 1 $tokens_name tokens

    set output ""
    incr indent_level
    # constructor, function, or method
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    puts "label: $label, token: $token // in complie_subroutine before all"
    if { [is_subroutine $token] } {
        set output [new_node "<subroutineDec>\n" "<keyword> $token </keyword>\n" $indent_level]
        set tokens [lrange $tokens 1 end]
    } else {
        return ""
    }

    # void or type
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    puts "label: $label, token: $token // in complie_subroutine before void or type"
    if { $label == "keyword" && [is_type $token] } {
        set output [new_node $output "<keyword> $token </keyword>\n" $indent_level]
        set tokens [lrange $tokens 1 end]
    } else {
        error "ERROR: expected void or type after subroutineDec"
    }

    puts "output:\n$output // before subroutineName"
    # subroutineName
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "identifier" && [is_valid_identifier $token] } {
        puts "label: $label, token: $token // subroutineName"
        set output [new_node $output "<identifier> $token </identifier>\n" $indent_level]
        set tokens [lrange $tokens 1 end]
    } else {
        error "ERROR: expected subroutineName after subroutineDec"
    }

    # (
    set symbol [complie_symbol tokens "("]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing (. in complie_subroutine"
    }

    puts "output:\n$output // before parameterList"

    # parameterList
    set parameter_list [complie_parameterList tokens $indent_level]
    set output [new_node $output $parameter_list $indent_level]

    # )
    set symbol [complie_symbol tokens ")"]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing ). in complie_subroutine"
    }

    puts "output:\n$output // before subroutineBody"

    # subroutineBody
    set subroutine_body [complie_subroutineBody tokens $indent_level]
    set output [new_node $output $subroutine_body $indent_level]

    set output [new_node $output "</subroutineDec>\n" [expr $indent_level - 1]]
    return $output
}

# parameterList -> (type varName ("," type varName)*)?
proc complie_parameterList { tokens_name indent_level } {
    upvar 1 $tokens_name tokens

    set output "<parameterList>\n"
    incr indent_level
    set i 0
    foreach ntoken $tokens {
        set label [dict get $ntoken label]
        set token [dict get $ntoken token]
        puts "label: $label, token: $token // in complie_parameterList"
        if { $label == "keyword" && [is_type $token] && ($i % 3) == 0 } {
            set output [new_node $output "<keyword> $token </keyword>\n" $indent_level]
            set tokens [lrange $tokens 1 end]
        } elseif { $label == "identifier" && [is_valid_identifier $token] && ($i % 3) == 1 } {
            set output [new_node $output "<identifier> $token </identifier>\n" $indent_level]
            set tokens [lrange $tokens 1 end]
        } elseif { $label == "symbol" && $token == "," && ($i % 3) == 2 } {
            set output [new_node $output "<symbol> , </symbol>\n" $indent_level]
            set tokens [lrange $tokens 1 end]
        } else {
            break
        }
        incr i
    }

    set output [new_node $output "</parameterList>\n" [expr $indent_level - 1]]

    return $output
}

# subroutineBody -> "{" varDec* statements "}"
proc complie_subroutineBody { tokens_name indent_level } {
    upvar 1 $tokens_name tokens
    incr indent_level

    set output "<subroutineBody>\n"

    # {
    set symbol [complie_symbol tokens "\{"]
    set output [new_node $output $symbol $indent_level]

    puts "output:\n$output // before varDec*"

    # varDec*
    set var_dec [complie_varDec tokens $indent_level]
    while { $var_dec != "" } {
        set output [new_node $output $var_dec $indent_level]
        set var_dec [complie_varDec tokens $indent_level]
    }

    puts "output:\n$output // before statements after varDec*"

    # statements
    set statements [complie_statements tokens $indent_level]
    set output [new_node $output $statements $indent_level]

    puts "output:\n$output // after statements"

    # }
    set symbol [complie_symbol tokens "\}"]
    set output [new_node $output $symbol $indent_level]

    set output [new_node $output "</subroutineBody>\n" [expr $indent_level - 1]]

    return $output
}

# varDec -> "var" type varName ("," varName)* ";"
proc complie_varDec { tokens_name indent_level } {
    upvar 1 $tokens_name tokens

    incr indent_level
    set output ""
    # var
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "keyword" && $token == "var" } {
        set output [new_node "<varDec>\n" "<keyword> var </keyword>\n" $indent_level]
        set tokens [lrange $tokens 1 end]
    } else {
        return ""
    }

    # type
    set type [complie_type tokens]
    set output [new_node $output $type $indent_level]

    # varName
    set var_name [complie_varName tokens]
    set output [new_node $output $var_name $indent_level]

    # ("," varName)*
    set i 0
    foreach ntoken $tokens {
        set label [dict get $ntoken label]
        set token [dict get $ntoken token]
        if { $label == "symbol" && $token == "," && ($i % 2) == 0 } {
            set output [new_node $output "<symbol> , </symbol>\n" $indent_level]
            set tokens [lrange $tokens 1 end]
        } elseif { $label == "identifier" && [is_valid_identifier $token] && ($i % 2) == 1 } {
            set output [new_node $output "<identifier> $token </identifier>\n" $indent_level]
            set tokens [lrange $tokens 1 end]
        } else {
            break
        }
        incr i
    }

    # ;
    set symbol [complie_symbol tokens ";"]
    if { $symbol != "" } {
        set output [new_node $output $symbol $indent_level]
    } else {
        error "invalid statement missing ;. in complie_varDec"
    }

    set output [new_node $output "</varDec>\n" [expr $indent_level - 1]]
    return $output
}

proc complie_type { tokens_name } {
    upvar 1 $tokens_name tokens

    set output ""
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "keyword" && [is_type $token] } {
        set output "<keyword> $token </keyword>\n"
        set tokens [lrange $tokens 1 end]
    } elseif { $label == "identifier" && [is_valid_identifier $token] } {
        set output "<identifier> $token </identifier>\n"
        set tokens [lrange $tokens 1 end]
    }
    return $output
}

proc complie_varName { tokens_name } {
    upvar 1 $tokens_name tokens

    set output ""
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "identifier" && [is_valid_identifier $token] } {
        set output "<identifier> $token </identifier>\n"
        set tokens [lrange $tokens 1 end]
    }
    return $output
}