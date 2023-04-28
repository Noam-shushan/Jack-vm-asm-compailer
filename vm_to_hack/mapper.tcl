source "compute_cmd.tcl"
source "flow_ctlr_cmd.tcl"
source "stack_cmd/push_cmd.tcl"
source "stack_cmd/pop_cmd.tcl"

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
            return [binary_operation "+"]
        }
        "sub" {
            return [binary_operation "-"]
        }
        "and" {
            return [binary_operation "&"]
        }
        "or" {
            return [binary_operation "|"]
        }
        "not" {
            return [onary_operation "!"]
        }
        "neg" {
            return [onary_operation "-"]
        }
        "eq" {
            return [compare_operation "JEQ"]
        }
        "gt" {
            return [compare_operation "JGT"]
        }
        "lt" {
            return [compare_operation "JLT"]
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

