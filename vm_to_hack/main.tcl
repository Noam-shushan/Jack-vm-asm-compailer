# Noam Shushan 314717588
# Shmoel Biscerg 324485101

source "../file_handler.tcl"
source "parser.tcl"
source "function_call.tcl"


proc get_vm_code {dir vm_file} {
    set vm_file_name [file tail $vm_file]
    puts "main -> vm_file_name: $vm_file_name"

    set file_path [file join $dir $vm_file_name]
    
    # read the .vm file
    set vm_code [read_file $file_path]
    return $vm_code
}


# run: tclsh main.tcl ../projects/07/StackArithmetic/SimpleAdd/
if {[info script] eq $argv0} {
    # check if the user entered a directory path
    if {[llength $argv] != 1} {
        puts "Usage: tclsh main.tcl <directory_path>"
        puts "Example: tclsh main.tcl ../projects/07/StackArithmetic/SimpleAdd/"
        exit 1
    }

    # get the path of the directory containing the .vm files from the command line argument
    set dir [lindex $argv 0]
    # get all .vm files in the directory
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
        set asm_code [parse_vm_to_hack $vm_code $asm_file_name]
            
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
            set current_asm_code [parse_vm_to_hack $vm_code $asm_file_name]

            # add the file name as a comment
            lappend asm_code "// $vm_file\n"
            
            # concat the current asm code to the asm code list
            set asm_code [concat $asm_code $current_asm_code]
        }
        # write the asm code to a .asm file
        write_file $asm_file_path [join $asm_code ""]
    }
}
