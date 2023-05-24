source "compute_cmd.tcl"
source "flow_ctlr_cmd.tcl"
source "stack_cmd/push_cmd.tcl"
source "stack_cmd/pop_cmd.tcl"
source "function_call.tcl"

# map line of vm code to hack code
proc map_line {line file_name} {
    set line_split [split $line " "]
    puts "map_line -> line_split: $line_split"
    
    switch [llength $line_split] {
        1 {
            set cmd [lindex $line_split 0]
            puts "map_line -> cmd: $cmd"
            return [map_one_literal_cmd $cmd]
        }
        2 {
            set cmd [lindex $line_split 0]
            set label [lindex $line_split 1]
            
            puts "map_line -> cmd: $cmd, label: $label"
            
            return [map_tow_literal_cmd $cmd $label $file_name]
        }
        3 {
            set cmd [lindex $line_split 0]
            set segment [lindex $line_split 1]
            set value [lindex $line_split end]

            puts "map_line -> cmd: $cmd, segment: $segment, value: $value"
            return [map_three_literal_cmd $cmd $segment $value]
        }
        default {
            return ""
        }
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
        "return" {
            return [return_cmd]
        }
        default {
            return ""
        }
    }
}

proc map_tow_literal_cmd {cmd label file_name} {
    switch $cmd {
        "label" {
            return [label $label $file_name]
        }
        "goto" {
            return [goto $label $file_name]
        }
        "if-goto" {
            return [if_goto $label $file_name]
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
        "call" {
            return [call_cmd $segment $value]
        }
        "function" {
            return [func_cmd $segment $value]
        }
        default {
            return ""
        }
    }
}

