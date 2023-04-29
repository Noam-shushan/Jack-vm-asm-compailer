# push command
# the command is: push <segment> <value>, for example: push local 3  
# segment: local, argument, this, that, constant, temp, pointer, static
# value: index of the segment
# returns: a list of hack code
proc push {segment value} {   
    puts "push -> segment: $segment, value: $value"
    switch $segment {
        "constant" {
            return [push_constant $value]
        }
        "local" -
        "this" -
        "argument" - 
        "that" {
            return [push_local_argument_this_that $segment $value]
        }
        "temp" {
            return [push_temp $value]
        }
        "pointer" {
            return [push_pointer $value]
        }
        "static" {
            return [push_static $value]
        }
        default {
            return ""
        }
    }
}

# push constant
proc push_constant {const} {
    return [list "@$const" "D=A" "@SP" "A=M" "M=D" "@SP" "M=M+1"]
}

# push local, argument, this, that
proc push_local_argument_this_that {segment index} {
    set segment_value "LCL"
    if {$segment == "argument"} {
        set segment_value "ARG"
    } elseif {$segment == "this"} {
        set segment_value "THIS"
    } elseif {$segment == "that"} {
        set segment_value "THAT"
    }
    return [list "@$index" "D=A" "@$segment_value" "A=M" "AD=D+A" "D=M" "@SP" "A=M" "M=D" "@SP" "M=M+1"]
}


proc push_argument {index} {
    return [list "@ARG" "AD=M" "D=M" "@SP" "A=M" "M=D" "@SP" "M=M+1"]
}

proc push_temp {value} {
    if {$value > 7} {
        return ""
    }
    set index [expr $value + 5]
    return [list "@$index" "D=M" "@0" "A=M" "M=D" "@SP" "M=M+1"]
}

proc push_pointer {value} {
    if {$value == 0} {
        return [list "@3" "D=M" "@SP" "A=M" "M=D" "@SP" "M=M+1"]
    } elseif {$value == 1} {
        return [list "@4" "D=M" "@SP" "A=M" "M=D" "@SP" "M=M+1"]
    }
    else {
        return ""
    }
}

proc push_static {value} {
    set index [expr $value + 16]
    return [list "@$index" "D=M" "@SP" "A=M" "M=D" "@SP" "M=M+1"]
}
