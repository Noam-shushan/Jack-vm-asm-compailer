# Noam Shushan 314717588
# Shmoel Biscerg 324485101

source "../file_handler.tcl"
source "vm_to_hack.tcl"



# run: tclsh main.tcl ../projects/07/StackArithmetic/SimpleAdd/
if {[info script] eq $argv0} {
    # check if the user entered a directory path
    if {[llength $argv] != 1} {
        puts "Usage: tclsh main.tcl <directory_path>"
        puts "Example: tclsh main.tcl ../../projects/07/StackArithmetic/SimpleAdd/"
        exit 1
    }

    # get the path of the directory containing the .vm files from the command line argument
    set dir [lindex $argv 0]
    # get all .vm files in the directory
    vm_to_hack $dir
}
