
proc pop {segment value} {
    puts "pop -> segment: $segment, value: $value"

    if {$value == "none"} {
        return [list "@0" "M=M-1" "A=M" "D=M"]
    }
    switch $segment {
        "local" -
        "argument" - 
        "this" - 
        "that" {
            return [pop_local_this_that $segment $value]
        }
        "temp" {
            return [pop_temp $value]
        }
        "pointer" {
            return [pop_pointer $value]
        }
        "static" {
            return [pop_static $value]
        }
        default {
            return ""
        }
    }
}

# dictionary of the segments: 
# local: 1, argument: 2, this: 3, that: 4
set _segments_dict [dict create local 1 argument 2 this 3 that 4]


proc pop_local_this_that {segment value} {
    set segment_value [dict get $_segments_dict $segment]
    return [list "@$segment_value" "D=M" "@$value" "D=D+A" "@0" "M=M-1" "A=M" "A=M" "A=A+D" "D=A-D" "A=A-D" "M=D"]
}

proc pop_temp {value} {
    set index [expr $value + 5]
    return [list "@$index" "D=A" "@0" "M=M-1" "A=M" "A=M" "A=A+D" "D=A-D" "A=A-D" "M=D"]
}

proc pop_pointer {value} {
    if {$value == 0} {
        return [list "@3" "D=A" "@0" "M=M-1" "A=M" "A=M" "A=A+D" "D=A-D" "A=A-D" "M=D"]
    } else {
        return [list "@4" "D=A" "@0" "M=M-1" "A=M" "A=M" "A=A+D" "D=A-D" "A=A-D" "M=D"]
    }
}

proc pop_static {value} {
    set index [expr $value + 16]
    return [list "@0" "M=M-1" "A=M" "D=M" "@$index" "M=D"]
}