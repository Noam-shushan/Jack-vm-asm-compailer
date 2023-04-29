# Noam Shushan 314717588
# Shmoel Biscerg 324485101

source "../file_handler.tcl"
source "parser.tcl"


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

    # loop through all .vm files in the directory
    foreach vm_file $vm_files {
        # get the name of the .vm file
        set vm_file_name [file tail $vm_file]
        puts "main -> vm_file_name: $vm_file_name"
        
        set file_path [file join $dir $vm_file_name]
        
        # read the .vm file
        set vm_code [read_file $file_path]
        
        # convert the vm code to asm code
        set asm_code [parse_vm_to_hack $vm_code [file rootname $vm_file_name]]
        
        # set the name of the .asm file to be the same as the .vm file
        set asm_file_name [string map {".vm" ".asm"} $vm_file_name]
        set asm_file_path "$dir$asm_file_name"
        
        # write the asm code to a .asm file
        write_file $asm_file_path [join $asm_code ""]
    }
}
