source "files_handler.tcl"
source "compiler.tcl"



if {[info script] eq $argv0} {
    set path "../projects/07/StackArithmetic/StackTest/"
    set vm_file_name "StackTest.vm"
    set file_path [file join $path $vm_file_name]
    set vm_code [read_file $file_path]
    set asm_code [convert_vm_to_hack $vm_code]
    set asm_file_name [string map {".vm" ".asm"} $vm_file_name]
    set asm_file_path "$path$asm_file_name"
    write_file $asm_file_path [join $asm_code "\n"]
}
