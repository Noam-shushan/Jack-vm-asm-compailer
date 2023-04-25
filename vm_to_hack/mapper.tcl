source "compute_cmd.tcl"
source "flow_ctlr_cmd.tcl"
source "stack_cmd/push_cmd.tcl"
source "stack_cmd/pop_cmd.tcl"

# convert vm code to hack code
proc parse_vm_to_hack {vm_code} {
    set only_code_lines [remove_empty_and_commants $vm_code]

    puts "parse_vm_to_hack -> only_code_lines: $only_code_lines"

    set hack_code {}
    foreach line $only_code_lines {
        set result [map_line $line]
        if {$result eq ""} {
            error "invalid vm code line: '$line'"
        } else {
            puts "parse_vm_to_hack -> line: $line, result: $result"
            lappend hack_code {*}$result
        }
    }
    return $hack_code
}

proc remove_empty_and_commants {vm_code} {
    set only_code_lines [list]
    foreach line [split $vm_code "\n"] {
        set line [string trim $line]
        if {$line ne "" && ![regexp {^\s*//} $line]} {
            lappend only_code_lines $line
        }
    }
    return $only_code_lines
}

# map line of vm code to hack code
proc map_line {line} {
    set line_split [split $line " "]
    puts "map_line -> line_split: $line_split"
    
    if {[llength $line_split] == 1} {
        set cmd [lindex $line_split 0]
        puts "map_line -> cmd: $cmd"
        return [map_one_literal_cmd $cmd]
    } elseif {[llength $line_split] == 3} {
        set cmd [lindex $line_split 0]
        set segment [lindex $line_split 1]
        set value [lindex $line_split end]

        puts "map_line -> cmd: $cmd"
        puts "map_line -> segment: $segment"
        puts "map_line -> value: $value"

        return [map_three_literal_cmd $cmd $segment $value]
    } else {
        return ""
    }
}


proc map_one_literal_cmd {cmd} {
    switch $cmd {
        "add" {
            return [arithmetic_operation "+"]
        }
        "sub" {
            return [arithmetic_operation "-"]
        }
        "and" {
            return [logical_operation "&"]
        }
        "or" {
            return [logical_operation "|"]
        }
        "not" {
            return [list "@0" "A=M-1" "M=!M"]
        }
        "neg" {
            return [list "@0" "A=M-1" "M=-M"]
        }
        "eq" {
            return [list "@0" "M=M-1" "A=M" "D=M" "@0" "A=M-1" "D=D-M" "@IF_TRUE" "D;JEQ" "@0" "A=M-1" "M=0" "@IF_FALSE" "0;JMP" "(IF_TRUE)" "@0" "A=M-1" "M=-1" "(IF_FALSE)"]
        }
        "gt" {
            return [list "@0" "M=M-1" "A=M" "D=M" "@0" "A=M-1" "D=D-M" "@IF_TRUE" "D;JLE" "@0" "A=M-1" "M=0" "@IF_FALSE" "0;JMP" "(IF_TRUE)" "@0" "A=M-1" "M=-1" "(IF_FALSE)"]
        }
        "lt" {
            return [list "@0" "M=M-1" "A=M" "D=M" "@0" "A=M-1" "D=D-M" "@IF_TRUE" "D;JGE" "@0" "A=M-1" "M=0" "@IF_FALSE" "0;JMP" "(IF_TRUE)" "@0" "A=M-1" "M=-1" "(IF_FALSE)"]
        }
        default {
            return ""
        }
    }
}

proc map_three_literal_cmd {cmd segment value} {
    switch $cmd {
        "push" {
            return [push $segment $value]
        }
        "pop" {
            return [pop $segment $value]
        }
        default {
            return ""
        }
    }
}

