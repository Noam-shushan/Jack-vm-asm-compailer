
proc pop {segment value} {
    puts "pop -> segment: $segment, value: $value"
    switch $segment {
        "local" -
        "argument" -
        "this" - 
        "that" {
            return [pop_local_argument_this_that $segment $value]
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

proc pop_local_argument_this_that {segment index} {
    set segment_value "LCL"
    if {$segment == "argument"} {
        set segment_value "ARG"
    } elseif {$segment == "this"} {
        set segment_value "THIS"
    } elseif {$segment == "that"} {
        set segment_value "THAT"
    }
    return [list "@SP" "M=M-1" "@$index" "D=A" "@$segment_value" "A=M" "AD=D+A" "@R13" "M=D" "@SP" "A=M" "D=M" "@R13" "A=M" "M=D"]
}

proc pop_this_that {segment value} {
    puts "pop_this_that -> segment: $segment, value: $value"
    set segment_value [expr {$segment eq "this" ? "THIS" : "THAT"}]
    set bagin [list "@0" "A=M-1" "D=M" "@$segment_value" "A=M"]
    # repeat A=A+1 value times
    set middle [lrepeat $value "A=A+1"]
    set end [list "M=D" "@0" "M=M-1"]
    return [concat $bagin $middle $end]
}

proc pop_temp {value} {
    set index [expr $value + 5]
    return [list "@SP" "A=M-1" "D=A" "@$index" "M=D" "@SP" "M=M-1"]
}

proc pop_pointer {value} {
    if {$value == 0} {
        return [list "@SP" "A=M-1" "D=M" "@3" "M=D" "@SP" "M=M-1"]
    } elseif {$value == 1} {
        return [list "@SP" "A=M-1" "D=M" "@4" "M=D" "@SP" "M=M-1"]
    } else {
        return ""
    }
}

proc pop_static {value} {
    set index [expr $value + 16]
    return [list "@SP" "M=M-1" "A=M" "D=M" "@$index" "M=D"]
}
