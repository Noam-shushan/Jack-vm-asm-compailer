
proc pop {segment value} {
    puts "pop -> segment: $segment, value: $value"
    switch $segment {
        "local" -
        "argument" {
            return [pop_local_argument $segment $value]
        }
        "this" - 
        "that" {
            return [pop_this_that $segment $value]
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

proc pop_local_argument {segment value} {
    set segment_value [expr {$segment == "local" ? 1 : 2}]
    return [list "@$segment_value" "D=M" "@$value" "D=D+A" "@0" "M=M-1" "A=M" "A=M" "A=A+D" "D=A-D" "A=A-D" "M=D"]
}

proc pop_this_that {segment value} {
    puts "pop_this_that -> segment: $segment, value: $value"
    set segment_value [expr {$segment eq "this" ? 3 : 4}]
    set bagin [list "@0" "A=M-1" "D=M" "@$segment_value" "A=M"]
    set middle [lrepeat $value "A=A+1"]
    set end [list "M=D" "@0" "M=M-1"]
    return [concat $bagin $middle $end]
}

proc pop_temp {value} {
    set index [expr $value + 5]
    return [list "@0" "A=M-1" "D=A" "@$index" "M=D" "@0" "M=M-1"]
}

proc pop_pointer {value} {
    if {$value == 0} {
        return [list "@0" "A=M-1" "D=M" "@3" "M=D" "@0" "M=M-1"]
    } elseif {$value == 1} {
        return [list "@0" "A=M-1" "D=M" "@4" "M=D" "@0" "M=M-1"]
    } else {
        return ""
    }
}

proc pop_static {value} {
    set index [expr $value + 16]
    return [list "@0" "M=M-1" "A=M" "D=M" "@$index" "M=D"]
}
