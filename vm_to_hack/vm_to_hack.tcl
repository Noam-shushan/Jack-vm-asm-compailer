source [file join [file dirname [info script]] "mapper.tcl"]
source [file join [file dirname [info script]] "function_call.tcl"]



proc vm_to_hack { dir } {
    set vm_files [glob -directory $dir -types f -tails *.vm]
    puts "main -> path: $dir, vm_files: $vm_files"

    set path_split [split $dir "/"]
    set asm_file_name [lindex $path_split [expr {[llength $path_split] - 2}]]
    set asm_file_path "$dir$asm_file_name.asm"
    puts "main -> asm_file_name: $asm_file_name, asm_file_path: $asm_file_path"

    if {[llength $vm_files] == 0} {
        puts "No .vm files found in the directory"
        exit 1
    }
    if {[llength $vm_files] == 1} {
        set vm_file [lindex $vm_files 0]
        set vm_code [get_vm_code $dir $vm_file]
        set asm_code [vm_to_hack_file $vm_code $asm_file_name]

        # write the asm code to a .asm file
        write_file $asm_file_path [join $asm_code ""]
    } else {
        puts "Found [llength $vm_files] .vm files in the directory"

        set asm_code [list]
        lappend asm_code [join [bootstrap] "\n"]
        puts "main -> asm_code: $asm_code"

        # loop through all .vm files in the directory
        foreach vm_file $vm_files {
            # read the .vm file
            set vm_code [get_vm_code $dir $vm_file]

            # convert the vm code to asm code
            set current_asm_code [vm_to_hack_file $vm_code $asm_file_name]

            # add the file name as a comment
            lappend asm_code "// $vm_file\n"

            # concat the current asm code to the asm code list
            set asm_code [concat $asm_code $current_asm_code]
        }
        # write the asm code to a .asm file
        write_file $asm_file_path [join $asm_code ""]
    }
}


# convert vm code to hack code
# vm_code: vm code
# file_name: the vm file name without extension (e.g. "SimpleAdd")
proc vm_to_hack_file {vm_code file_name} {
    set only_code_lines [remove_empty_and_commants $vm_code]

    puts "parse_vm_to_hack -> only_code_lines: $only_code_lines"

    set hack_code {}
    foreach line $only_code_lines {
        set result [map_line $line $file_name]
        if {$result eq ""} {
            error "invalid vm code line: '$line'"
        } else {
            puts "parse_vm_to_hack -> line: $line, result: $result"

            lappend hack_code "// $line\n"
            set joind_result [join $result "\n"]
            lappend hack_code "$joind_result\n\n"
        }
    }
    return $hack_code
}

proc get_vm_code {dir vm_file} {
    set vm_file_name [file tail $vm_file]
    puts "main -> vm_file_name: $vm_file_name"

    set file_path [file join $dir $vm_file_name]

    # read the .vm file
    set vm_code [read_file $file_path]
    return $vm_code
}

proc remove_empty_and_commants {vm_code} {
    set only_code_lines [list]
    foreach line [split $vm_code "\n"] {
        set line [string trim $line]
        if {$line ne "" && ![regexp {^\s*//} $line]} {
            lappend only_code_lines [remove_inline_comments $line]
        }
    }
    return $only_code_lines
}

proc remove_inline_comments {line} {
    return [string trim [lindex [split $line "//"] 0] ]
}