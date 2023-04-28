source "mapper.tcl"

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
            
            lappend hack_code "// $line\n"
            # add new line after the result 
            set joind_result [join $result "\n"]
            lappend hack_code $joind_result "\n\n"
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