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
        "that" {
            return [push_local_this_that $segment $value]
        }
        "argument" {
            return [push_argument $value]
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
    return [list "@$const" "D=A" "@0" "A=M" "M=D" "@0" "M=M+1"]
}

# push local, argument, this, that
proc push_local_this_that {segment index} {
    set segment_value 1
    if {$segment == "argument"} {
        set segment_value 2
    } elseif {$segment == "this"} {
        set segment_value 3
    } elseif {$segment == "that"} {
        set segment_value 4
    }
    return [list "@$index" "D=A" "@$segment_value" "A=M+D" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
}

proc push_argument {index} {
    return [list "@2" "D=A" "@$index" "D=D+A" "A=D" "D=M" "@0" "M=D" "@0" "M=M+1"]
}

proc push_temp {value} {
    if {$value > 7} {
        return ""
    }
    set index [expr $value + 5]
    return [list "@$index" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
}

proc push_pointer {value} {
    if {$value == 0} {
        return [list "@3" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
    } elseif {$value == 1} {
        return [list "@4" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
    }
    else {
        return ""
    }
}

proc push_static {value} {
    set index [expr $value + 16]
    return [list "@$index" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
}
