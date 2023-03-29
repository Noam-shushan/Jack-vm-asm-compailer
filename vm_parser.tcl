# vm code to hack code

# dictionary of the segments: 
# local: 1, argument: 2, this: 3, that: 4
set segments_dict [dict create local 1 argument 2 this 3 that 4]

proc push_constant {const} {
    return [list "@$const" "D=A" "@0" "A=M" "M=D" "@0" "M=M+1"]
}

proc arithmetic_operation {operator} {
    return [list "@0" "A=M-1" "D=M" "A=A-1" "M=D$operator M" "@0" "M=M-1"]
}

proc logical_operation {operator} {
    return [list "@0" "M=M-1" "A=M" "D=M" "A=A-1" "M=D$operator M"]
}

proc push_local_arg_this_that {index, segment} {
    return [list "@$index" "D=A" "@$segment" "A=D+M" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
}

proc push {segment, value} {   
    puts $segment
    puts $value 
    switch $segment {
        "constant" {
            return [push_constant $value]
        }
        "local" -
        "argument" - 
        "this" - 
        "that" {
            set segment_value [dict get $segments_dict $segment]
            return [push_local_arg_this_that $value $segment_value]
        }
        "temp" {
            set index [expr $value + 5]
            return [list "@$index" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
        }
        "pointer" {
            if {$value == 0} {
                return [list "@3" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
            } else {
                return [list "@4" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
            }
        }
        "static" {
            set index [expr $value + 16]
            return [list "@$index" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
        }
        default {
            return [list "error"]
        }
    }
}

proc pop {segment, value} {
    if {$value == "none"} {
        return [list "@0" "M=M-1" "A=M" "D=M"]
    }
    switch $segment {
        "local" -
        "argument" - 
        "this" - 
        "that" {
            set segment_value [dict get $segments_dict $segment]
            return [list "@$segment_value" "D=M" "@$value" "D=D+A" "@0" "M=M-1" "A=M" "A=M" "A=A+D" "D=A-D" "A=A-D" "M=D"]
        }
        "temp" {
            set index [expr $value + 5]
            return [list "@$index" "D=A" "@0" "M=M-1" "A=M" "A=M" "A=A+D" "D=A-D" "A=A-D" "M=D"]
        }
        "pointer" {
            if {$value == 0} {
                return [list "@0" "M=M-1" "A=M" "D=M" "@3" "M=D"]
            } else {
                return [list "@0" "M=M-1" "A=M" "D=M" "@4" "M=D"]
            }
        }
        "static" {
            set index [expr $value + 16]
            return [list "@0" "M=M-1" "A=M" "D=M" "@$index" "M=D"]
        }
        default {
            return [list "error"]}
    }
}

# map line of vm code to hack code
proc map_line {line} {
    set line_split [split $line " "]
    set command [lindex $line_split 0]
    set segment [lindex $line_split 1]
    set value [lindex $line_split end]
    puts $command
    puts $segment
    puts $value
    
    switch $command {
        "push" {
            puts $segment
            return [push $segment $value]
        }
        "pop" {
            return [pop $segment $value]
        }
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
            return "ERROR: unknown command"
        }
    }
}

# convert vm code to hack code
proc parse_vm_to_hack {vm_code} {
    # remove comments and empty lines
    set only_code_lines [split $vm_code "\n"]
    set only_code_lines [lmap line $only_code_lines {
        if {![regexp {^\s*//} $line] && [string trim $line] ne ""} {
        string trim $line
        }
    }]

    set hack_code {}
    foreach line $only_code_lines {
        set result [map_line $line]
        if {$result ne ""} {
            lappend hack_code {*}$result
        }
    }
    return $hack_code
}