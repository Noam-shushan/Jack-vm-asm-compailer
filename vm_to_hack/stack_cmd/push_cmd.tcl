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
        "argument" - 
        "this" - 
        "that" {
            return [push_local_arg_this_that $segment $value]
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
            return [list]
        }
    }
}

# dictionary of the segments: 
# local: 1, argument: 2, this: 3, that: 4
set segments_dict [dict create local 1 argument 2 this 3 that 4]

# push constant
proc push_constant {const} {
    return [list "@$const" "D=A" "@0" "A=M" "M=D" "@0" "M=M+1"]
}

# push local, argument, this, that
proc push_local_arg_this_that {segment index} {
    set segment_value [dict get $segments_dict $segment]
    return [list "@$index" "D=A" "@$segment_value" "A=D+M" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
}

proc push_temp {value} {
    set index [expr $value + 5]
    return [list "@$index" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
}

proc push_pointer {value} {
    if {$value == 0} {
        return [list "@3" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
    } else {
        return [list "@4" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
    }
}

proc push_static {value} {
    set index [expr $value + 16]
    return [list "@$index" "D=M" "@0" "A=M" "M=D" "@0" "M=M+1"]
}
