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
    
    set output ""
    # class
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "keyword" && $token == "class" } {
        set output "<class>\n"
        set output "$output  <keyword> class </keyword>\n"
        set tokens [lrange $tokens 1 end]
    } else {
        error "ERROR: expected class. in complie_class"
    }
    
    # className
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set identifier [dict get $next_token token]
    if { $label == "identifier" } {
        set output "$output  <identifier> $identifier </identifier>\n"
        set tokens [lrange $tokens 1 end]
    } else {
        error "ERROR: expected class name. in complie_class"
    }
    
    # {
    set symbol [complie_symbol tokens "{"]
    puts "symbol: $symbol"
    if { $symbol != "" } {
        set output "$output  $symbol"
    } else {
        error "invalid statement missing '\{'. in complie_class"
    }
    puts "output:\n$output"
    set next_token [lindex $tokens 0]

    set class_var_dec [complie_classVarDec tokens]
    set output "$output  $class_var_dec"
    puts "output:\n$output // after complie_classVarDec"

    set subroutine [complie_subroutine tokens]
    set output "$output  $subroutine"
    puts "output:\n$output // after complie_subroutine"

    # }
    set symbol [complie_symbol tokens "}"]
    if { $symbol != "" } {
        set output "$output  $symbol"
    } else {
        error "invalid statement missing \}. in complie_class"
    }
    set output "$output</class>\n"
    return $output
}

# classVarDec -> ("static" | "field") type varName ("," varName)* ";"
proc complie_classVarDec { tokens_name } {
    upvar 1 $tokens_name tokens

    set output ""
    # static or field
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "keyword" 
        && [expr { $token == "static" || $token == "field"}] } { 
        set output "<classVarDec>\n"
        set output "$output  <keyword> $token </keyword>\n"
        set tokens [lrange $tokens 1 end]
    } else {
        return ""
    }


    # type
    set type [complie_type tokens]
    set output "$output  $type"

    # varName
    set i 0
    foreach ntoken $tokens { 
        set label [dict get $ntoken label]
        set token [dict get $ntoken token]
        if { $label == "identifier" && ($i % 2) == 0 } {
            set output "$output  <identifier> $token </identifier>\n"
            set tokens [lrange $tokens 1 end]
        } elseif { $label == "symbol" && $token == "," && ($i % 2) == 1 } {
            set output "$output  <symbol> , </symbol>\n"
            set tokens [lrange $tokens 1 end] 
        } else {
            break
        }
        incr i
    }
    # ;
    set symbol [complie_symbol tokens ";"]
    if { $symbol != "" } {
        set output "$output  $symbol"
    } else {
        error "invalid statement missing ;. in complie_classVarDec"
    }
    set output "$output </classVarDec>\n"
}

# subroutineDec -> ("constructor" | "function" | "method") 
#                  ("void" | type) subroutineName 
#                  "(" parameterList ")" subroutineBody
proc complie_subroutine { tokens_name } {
    upvar 1 $tokens_name tokens

    set output ""
    
    # constructor, function, or method
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    puts "label: $label, token: $token // in complie_subroutine before all"
    if { [is_subroutine $token] } { 
        set output "<subroutineDec>\n"
        set output "$output  <keyword> $token </keyword>\n"
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
        set output "$output  <keyword> $token </keyword>\n"
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
        set output "$output  <identifier> $token </identifier>\n"
        set tokens [lrange $tokens 1 end]
    } else {
        error "ERROR: expected subroutineName after subroutineDec"
    }
    
    # (
    set symbol [complie_symbol tokens "("]
    if { $symbol != "" } {
        set output "$output  $symbol"
    } else {
        error "invalid statement missing (. in complie_subroutine"
    }

    puts "output:\n$output // before parameterList"

    # parameterList
    set parameter_list [complie_parameterList tokens]
    set output "$output  $parameter_list"
    
    # )
    set symbol [complie_symbol tokens ")"]
    if { $symbol != "" } {
        set output "$output  $symbol"
    } else {
        error "invalid statement missing ). in complie_subroutine"
    }

    puts "output:\n$output // before subroutineBody"

    # subroutineBody
    set subroutine_body [complie_subroutineBody tokens]
    set output "$output  $subroutine_body\n"
    
    set output "$output</subroutineDec>\n"
    return $output
}

# parameterList -> (type varName ("," type varName)*)?
proc complie_parameterList { tokens_name } {
    upvar 1 $tokens_name tokens

    set output "<parameterList>\n"
    set i 0
    foreach ntoken $tokens { 
        set label [dict get $ntoken label]
        set token [dict get $ntoken token]
        puts "label: $label, token: $token // in complie_parameterList"
        if { $label == "keyword" && [is_type $token] && ($i % 3) == 0 } {
            set output "$output  <keyword> $token </keyword>\n"
            set tokens [lrange $tokens 1 end]
        } elseif { $label == "identifier" && [is_valid_identifier $token] && ($i % 3) == 1 } {
            set output "$output  <identifier> $token </identifier>\n"
            set tokens [lrange $tokens 1 end]
        } elseif { $label == "symbol" && $token == "," && ($i % 3) == 2 } {
            set output "$output  <symbol> , </symbol>\n"
            set tokens [lrange $tokens 1 end] 
        } else {
            break
        }
        incr i
    }
    set output "$output</parameterList>\n"
    return $output
}
# subroutineBody -> "{" varDec* statements "}"
proc complie_subroutineBody { tokens_name } {
    upvar 1 $tokens_name tokens

    set output "<subroutineBody>\n"
    # {
    set symbol [complie_symbol tokens "\{"]
    if { $symbol != "" } {
        set output "$output  $symbol"
    } else {
        error "invalid statement missing \{. in complie_subroutineBody"
    }

    puts "output:\n$output // before varDec"

    # varDec*
    set var_dec [complie_varDec tokens]
    set output "$output  $var_dec"

    puts "output:\n$output // before statements"
    
    # statements
    set statements [complie_statements tokens]
    set output "$output  $statements"

    puts "output:\n$output // after statements"
    
    # }
    set symbol [complie_symbol tokens "\}"]
    if { $symbol != "" } {
        set output "$output  $symbol"
    } else {
        error "invalid statement missing \}. in complie_subroutineBody"
    }

    set output "$output</subroutineBody>\n"
    return $output
}

# varDec -> "var" type varName ("," varName)* ";"
proc complie_varDec { tokens_name } {
    upvar 1 $tokens_name tokens

    set output ""
    # var
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "keyword" && $token == "var" } {
        set output "<varDec>\n" 
        set output "$output  <keyword> var </keyword>\n"
        set tokens [lrange $tokens 1 end]
    } else {
        return ""
    }
    
    # type
    set type [complie_type tokens]
    set output "$output  $type"
    
    # varName
    set var_name [complie_varName tokens]
    set output "$output  $var_name"
    
    # ("," varName)*
    set i 0
    foreach ntoken $tokens { 
        set label [dict get $ntoken label]
        set token [dict get $ntoken token]
        if { $label == "symbol" && $token == "," && ($i % 2) == 0 } {
            set output "$output  <symbol> , </symbol>\n"
            set tokens [lrange $tokens 1 end] 
        } elseif { $label == "identifier" && [is_valid_identifier $token] && ($i % 2) == 1 } {
            set output "$output  <identifier> $token </identifier>\n"
            set tokens [lrange $tokens 1 end]
        } else {
            break
        }
        incr i
    }

    # ;
    set symbol [complie_symbol tokens ";"]
    if { $symbol != "" } {
        set output "$output  $symbol"
    } else {
        error "invalid statement missing ;. in complie_varDec"
    }

    set output "$output</varDec>\n"
    return $output
}

proc complie_type { tokens_name } {
    upvar 1 $tokens_name tokens

    set output ""
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    puts "label: $label, token: $token // in complie_type"
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